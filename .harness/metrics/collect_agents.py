#!/usr/bin/env python3
"""
로컬 에이전트 세션 로그(Claude Code · Codex)에서 이 레포 작업의 토큰 · 시간 · 도구 호출을 집계한다.

사용: python3 .harness/metrics/collect_agents.py [--since YYYY-MM-DD] [--until YYYY-MM-DD]
  - 읽는 곳: ~/.claude/projects/<레포 경로>/ · ~/.codex/sessions/  (읽기만 한다)
  - 결과: 표준 출력에 Markdown 요약, .harness/metrics/out/agents-<날짜>.json 에 세션별 집계값.
  - 프롬프트 · 응답 · 도구 입출력 내용은 읽어 들이지만 저장하지 않는다. 숫자(토큰 · 횟수 · 시간)만 남긴다.

지표 정의는 .harness/metrics/README.md 참고.
"""
import argparse
import json
import statistics
import sys
from collections import Counter
from datetime import datetime, timedelta, timezone
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
OUT_DIR = REPO_ROOT / ".harness/metrics/out"
CLAUDE_DIR = Path.home() / ".claude/projects" / str(REPO_ROOT).replace("/", "-")
CODEX_DIR = Path.home() / ".codex/sessions"
# 이 간격보다 긴 공백은 자리를 비운 것으로 보고 작업 시간에서 뺀다.
IDLE_GAP = timedelta(minutes=10)
SUBAGENT_TOOLS = {"Agent", "Task"}


def parse_time(value):
    return datetime.fromisoformat(value.replace("Z", "+00:00")) if value else None


def active_minutes(timestamps):
    ts = sorted(timestamps)
    total = sum((b - a for a, b in zip(ts, ts[1:]) if b - a <= IDLE_GAP), timedelta())
    return round(total.total_seconds() / 60, 1)


def read_jsonl(path):
    with open(path, encoding="utf-8") as f:
        for line in f:
            try:
                yield json.loads(line)
            except json.JSONDecodeError:
                continue


def claude_session(main_file):
    """메인 대화 + (있으면) <세션>/subagents/*.jsonl 을 한 세션으로 묶는다."""
    files = [main_file, *sorted((main_file.parent / main_file.stem / "subagents").glob("*.jsonl"))]
    seen, timestamps = set(), []
    tokens = Counter()
    sub_tokens = Counter()
    models, tools = Counter(), Counter()
    for path in files:
        is_sub_file = path != main_file
        for d in read_jsonl(path):
            ts = parse_time(d.get("timestamp"))
            if ts:
                timestamps.append(ts)
            if d.get("type") != "assistant":
                continue
            msg = d.get("message") or {}
            for block in msg.get("content") or []:
                if isinstance(block, dict) and block.get("type") == "tool_use":
                    tools[block.get("name")] += 1
            # 한 응답이 콘텐츠 블록마다 여러 줄로 기록된다 → message.id 로 한 번만 센다.
            mid = msg.get("id")
            # <synthetic>: 클라이언트가 만든 가짜 응답 (API 호출 아님)
            if not mid or mid in seen or msg.get("model") == "<synthetic>":
                continue
            seen.add(mid)
            usage = msg.get("usage") or {}
            target = sub_tokens if (is_sub_file or d.get("isSidechain")) else tokens
            for key in ("input_tokens", "cache_creation_input_tokens", "cache_read_input_tokens", "output_tokens"):
                target[key] += usage.get(key) or 0
            target["api_calls"] += 1
            models[msg.get("model")] += 1
    if not timestamps:
        return None
    return {
        "agent": "claude",
        "session": main_file.stem[:8],
        "started_at": min(timestamps).isoformat(timespec="seconds"),
        "active_min": active_minutes(timestamps),
        "api_calls": tokens["api_calls"] + sub_tokens["api_calls"],
        "input_tokens": tokens["input_tokens"] + sub_tokens["input_tokens"],
        "cache_write_tokens": tokens["cache_creation_input_tokens"] + sub_tokens["cache_creation_input_tokens"],
        "cache_read_tokens": tokens["cache_read_input_tokens"] + sub_tokens["cache_read_input_tokens"],
        "output_tokens": tokens["output_tokens"] + sub_tokens["output_tokens"],
        "subagent_calls": sum(tools[t] for t in SUBAGENT_TOOLS),
        "subagent_output_tokens": sub_tokens["output_tokens"],
        "tool_calls": sum(tools.values()),
        "models": dict(models),
    }


def codex_session(path):
    timestamps, models, last_usage, tool_calls, cwd = [], Counter(), None, 0, None
    for d in read_jsonl(path):
        ts = parse_time(d.get("timestamp"))
        if ts:
            timestamps.append(ts)
        payload = d.get("payload") if isinstance(d.get("payload"), dict) else {}
        kind = d.get("type")
        if kind == "session_meta" and cwd is None:
            cwd = payload.get("cwd")
        elif kind == "turn_context":
            models[payload.get("model")] += 1
        elif kind == "event_msg" and payload.get("type") == "token_count":
            # total_token_usage 는 세션 누적값 → 마지막 값이 세션 합계
            last_usage = (payload.get("info") or {}).get("total_token_usage") or last_usage
        elif kind == "response_item" and payload.get("type") in {"function_call", "custom_tool_call", "local_shell_call"}:
            tool_calls += 1
    if cwd is None or not (cwd == str(REPO_ROOT) or cwd.startswith(str(REPO_ROOT) + "/")) or not timestamps:
        return None
    usage = last_usage or {}
    cached = usage.get("cached_input_tokens") or 0
    return {
        "agent": "codex",
        "session": path.stem[-8:],
        "started_at": min(timestamps).isoformat(timespec="seconds"),
        "active_min": active_minutes(timestamps),
        "api_calls": None,
        # Codex 의 input_tokens 는 캐시 적중분을 포함한다 → Claude 와 같은 기준으로 분리
        "input_tokens": (usage.get("input_tokens") or 0) - cached,
        "cache_write_tokens": usage.get("cache_write_input_tokens") or 0,
        "cache_read_tokens": cached,
        "output_tokens": usage.get("output_tokens") or 0,
        "subagent_calls": 0,
        "subagent_output_tokens": 0,
        "tool_calls": tool_calls,
        "models": dict(models),
    }


def collect(since, until):
    sessions = []
    if CLAUDE_DIR.is_dir():
        sessions += [s for f in sorted(CLAUDE_DIR.glob("*.jsonl")) if (s := claude_session(f))]
    if CODEX_DIR.is_dir():
        sessions += [s for f in sorted(CODEX_DIR.rglob("*.jsonl")) if (s := codex_session(f))]

    def keep(s):
        ts = parse_time(s["started_at"])
        return (since is None or ts >= since) and (until is None or ts < until)

    return sorted(filter(keep, sessions), key=lambda s: s["started_at"])


def summarize(sessions):
    by_agent = {}
    for agent in ("claude", "codex"):
        ss = [s for s in sessions if s["agent"] == agent]
        if not ss:
            continue
        total_in = [s["input_tokens"] + s["cache_write_tokens"] + s["cache_read_tokens"] for s in ss]
        by_agent[agent] = {
            "sessions": len(ss),
            "active_hours": round(sum(s["active_min"] for s in ss) / 60, 1),
            "input_tokens_total": sum(total_in),
            "output_tokens_total": sum(s["output_tokens"] for s in ss),
            "cache_read_share_pct": round(sum(s["cache_read_tokens"] for s in ss) / sum(total_in) * 100, 1)
            if sum(total_in) else None,
            "median_input_per_session": round(statistics.median(total_in)),
            "median_output_per_session": round(statistics.median(s["output_tokens"] for s in ss)),
            "median_active_min": round(statistics.median(s["active_min"] for s in ss), 1),
            "tool_calls_total": sum(s["tool_calls"] for s in ss),
            "subagent_calls_total": sum(s["subagent_calls"] for s in ss),
        }
    return by_agent


def fmt(n):
    return f"{n:,}" if isinstance(n, int) else str(n)


def to_markdown(result):
    lines = [
        f"## 에이전트 지표 ({result['range']})",
        "",
        "| 지표 | " + " | ".join(result["summary"]) + " |",
        "|---|" + "---|" * len(result["summary"]),
    ]
    rows = [
        ("세션 수", "sessions"),
        ("작업 시간 합계 (시간, 10분 이상 공백 제외)", "active_hours"),
        ("입력 토큰 합계 (캐시 포함)", "input_tokens_total"),
        ("출력 토큰 합계", "output_tokens_total"),
        ("캐시 적중 비율", "cache_read_share_pct"),
        ("세션당 입력 토큰 (중앙값)", "median_input_per_session"),
        ("세션당 출력 토큰 (중앙값)", "median_output_per_session"),
        ("세션당 작업 시간 (중앙값, 분)", "median_active_min"),
        ("도구 호출 합계", "tool_calls_total"),
        ("서브에이전트 호출 합계", "subagent_calls_total"),
    ]
    for label, key in rows:
        lines.append(f"| {label} | " + " | ".join(fmt(v[key]) for v in result["summary"].values()) + " |")
    return "\n".join(lines)


def hook_events(since, until):
    """하네스 검사 기록 (Scripts/harness/events.py). 로컬에서 잡힌 위반 수 — CI 에서 처음 잡힌 수(collect_github)와 비교한다."""
    path = OUT_DIR / "hook-events.jsonl"
    if not path.exists():
        return None
    runs, rules, blocks = Counter(), Counter(), Counter()
    for d in read_jsonl(path):
        ts = parse_time(d.get("ts"))
        if not ts or (since and ts < since) or (until and ts >= until):
            continue
        if d.get("source") == "claude-pre-tool":
            blocks[(d.get("result"), d.get("reason"))] += 1
            continue
        runs[(d.get("source"), d.get("result"))] += 1
        rules.update(d.get("rules") or [])
    return {
        "runs": {f"{s}:{r}": n for (s, r), n in sorted(runs.items())},
        "violations_by_rule": dict(rules.most_common()),
        "pre_tool": {f"{r}: {reason}": n for (r, reason), n in blocks.most_common()},
    }


def hooks_markdown(h):
    if not h:
        return "\n## 하네스 검사 기록\n\n기록 없음 (`.harness/metrics/out/hook-events.jsonl`)"
    sources = sorted({k.split(":")[0] for k in h["runs"]})
    lines = ["", "## 하네스 검사 기록 (로컬)", "", "| 실행 위치 | 통과 | 위반 발견 |", "|---|---|---|"]
    for s in sources:
        lines.append(f"| {s} | {h['runs'].get(s + ':pass', 0)} | {h['runs'].get(s + ':fail', 0)} |")
    lines += ["", "- 규칙별 위반: " + (", ".join(f"{k} {v}" for k, v in h["violations_by_rule"].items()) or "없음")]
    lines += ["- 명령 · 파일 차단(deny) · 확인(ask): " + (", ".join(f"{k} ({v})" for k, v in h["pre_tool"].items()) or "없음")]
    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--since", help="이 날짜(포함) 이후 시작한 세션 (YYYY-MM-DD, UTC)")
    parser.add_argument("--until", help="이 날짜(제외) 이전 시작한 세션 (YYYY-MM-DD, UTC)")
    args = parser.parse_args()
    since = datetime.fromisoformat(args.since).replace(tzinfo=timezone.utc) if args.since else None
    until = datetime.fromisoformat(args.until).replace(tzinfo=timezone.utc) if args.until else None

    sessions = collect(since, until)
    result = {
        "range": f"{args.since or '처음'} ~ {args.until or '현재'}",
        "collected_at": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "summary": summarize(sessions),
        "hooks": hook_events(since, until),
        "sessions": sessions,
    }
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    out = OUT_DIR / f"agents-{datetime.now().strftime('%Y%m%d')}.json"
    out.write_text(json.dumps(result, ensure_ascii=False, indent=2))
    print(to_markdown(result))
    print(hooks_markdown(result["hooks"]))
    print(f"\n세션별 집계: {out.relative_to(REPO_ROOT)}", file=sys.stderr)


if __name__ == "__main__":
    main()
