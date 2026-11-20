#!/usr/bin/env python3
"""
GitHub PR · CI 이력으로 하네스 지표를 집계한다. (도입 전 기준선 · 도입 후 비교)

사용: python3 .harness/metrics/collect_github.py [--since YYYY-MM-DD] [--until YYYY-MM-DD]
  - gh CLI 인증이 필요하다. 조회만 한다 (쓰기 없음).
  - 결과: 표준 출력에 Markdown 요약, .harness/metrics/out/github-<날짜>.json 에 원본 집계값.

지표 정의는 .harness/metrics/README.md 참고.
"""
import argparse
import json
import statistics
import subprocess
import sys
from collections import Counter, defaultdict
from datetime import datetime, timezone
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
OUT_DIR = REPO_ROOT / ".harness/metrics/out"
CI_WORKFLOW = "iOS CI"
# 승격·역반영 PR 은 작업 PR 이 아니므로 작업 지표에서 뺀다.
PROMOTION_HEADS = {"dev", "staging", "main"}


def gh_json(args):
    out = subprocess.run(["gh", *args], check=True, capture_output=True, text=True).stdout
    return json.loads(out)


def repo_name():
    return gh_json(["repo", "view", "--json", "nameWithOwner"])["nameWithOwner"]


def parse_time(value):
    return datetime.fromisoformat(value.replace("Z", "+00:00")) if value else None


def in_range(ts, since, until):
    return (since is None or ts >= since) and (until is None or ts < until)


PR_TYPES = {"feat", "fix", "refactor", "chore", "ci", "test", "docs", "style", "release"}
TYPE_ALIASES = {"feature": "feat"}


def pr_type(pr):
    """제목 접두사(`feat: …`) → 없으면 브랜치 접두사(`feat/…`) 로 판정한다. (초기 PR 은 제목이 브랜치명)"""
    for raw in (pr["title"].split(":", 1)[0] if ":" in pr["title"] else "", pr["headRefName"].split("/", 1)[0]):
        head = TYPE_ALIASES.get(raw.strip().lower().split("(", 1)[0], raw.strip().lower().split("(", 1)[0])
        if head in PR_TYPES:
            return head
    return "other"


def median(values):
    return round(statistics.median(values), 1) if values else None


def rate(ok, total):
    return round(ok / total * 100, 1) if total else None


PR_QUERY = """
query($owner: String!, $name: String!, $cursor: String) {
  repository(owner: $owner, name: $name) {
    pullRequests(states: MERGED, first: 100, after: $cursor) {
      pageInfo { hasNextPage endCursor }
      nodes {
        number title headRefName baseRefName createdAt mergedAt
        additions deletions changedFiles
        commits(first: 1) { totalCount nodes { commit { authoredDate } } }
      }
    }
  }
}
"""


def fetch_prs(repo):
    # `gh pr list --json commits` 는 커밋 목록 전체를 가져와 GraphQL 노드 한도를 넘는다 → 개수만 조회
    owner, name = repo.split("/")
    prs, cursor = [], None
    while True:
        args = ["api", "graphql", "-f", f"query={PR_QUERY}", "-F", f"owner={owner}", "-F", f"name={name}"]
        if cursor:
            args += ["-F", f"cursor={cursor}"]
        page = gh_json(args)["data"]["repository"]["pullRequests"]
        prs += page["nodes"]
        if not page["pageInfo"]["hasNextPage"]:
            return prs
        cursor = page["pageInfo"]["endCursor"]


def fetch_runs(repo):
    runs = []
    page = 1
    while True:
        data = gh_json(["api", f"repos/{repo}/actions/runs?per_page=100&page={page}"])
        runs.extend(data["workflow_runs"])
        if len(data["workflow_runs"]) < 100:
            return runs
        page += 1


def failed_jobs(repo, run_id):
    jobs = gh_json(["api", f"repos/{repo}/actions/runs/{run_id}/jobs?per_page=100"])["jobs"]
    return [j["name"] for j in jobs if j["conclusion"] == "failure"]


def pr_metrics(prs, since, until):
    work = [
        p for p in prs
        if p["headRefName"] not in PROMOTION_HEADS and in_range(parse_time(p["mergedAt"]), since, until)
    ]
    types = Counter(pr_type(p) for p in work)
    # PR 을 머지 직전에 여는 경우가 많아 "PR 생성 → 머지" 는 의미가 없다 → 첫 커밋 → 머지 로 잰다.
    lead_hours = [
        (parse_time(p["mergedAt"]) - parse_time(p["commits"]["nodes"][0]["commit"]["authoredDate"])).total_seconds()
        / 3600
        for p in work
        if p["commits"]["nodes"]
    ]
    code_prs = types["feat"] + types["fix"] + types["refactor"]
    return {
        "work_prs": len(work),
        "by_type": dict(types),
        "fix_ratio_pct": rate(types["fix"], code_prs),
        "median_commits_per_pr": median([p["commits"]["totalCount"] for p in work]),
        "median_lead_time_hours": median(lead_hours),
        "median_changed_files": median([p["changedFiles"] for p in work]),
        "median_changed_lines": median([p["additions"] + p["deletions"] for p in work]),
    }


def ci_metrics(repo, runs, since, until):
    ci = [
        r for r in runs
        if r["name"] == CI_WORKFLOW and in_range(parse_time(r["created_at"]), since, until)
    ]
    finished = [r for r in ci if r["conclusion"] in {"success", "failure"}]

    def summarize(event):
        rs = sorted((r for r in finished if r["event"] == event), key=lambda r: r["created_at"])
        # PR 검사: 출발 브랜치별 첫 실행 / 큐: PR 번호별 첫 실행 → "최초 통과율"
        key = (lambda r: r["head_branch"].split("/pr-", 1)[-1].split("-", 1)[0]) if event == "merge_group" \
            else (lambda r: r["head_branch"])
        first = {}
        for r in rs:
            first.setdefault(key(r), r)
        durations = [
            (parse_time(r["updated_at"]) - parse_time(r["run_started_at"])).total_seconds() / 60 for r in rs
        ]
        return {
            "runs": len(rs),
            "success_rate_pct": rate(sum(r["conclusion"] == "success" for r in rs), len(rs)),
            "first_pass_rate_pct": rate(sum(r["conclusion"] == "success" for r in first.values()), len(first)),
            "first_pass_sample": len(first),
            "median_duration_min": median(durations),
        }

    failures = Counter()
    for r in finished:
        if r["conclusion"] == "failure":
            for name in failed_jobs(repo, r["id"]):
                failures[name] += 1

    return {
        "pull_request": summarize("pull_request"),
        "merge_group": summarize("merge_group"),
        "failed_jobs": dict(failures),
        "cancelled_runs": sum(r["conclusion"] == "cancelled" for r in ci),
        "first_run_at": min((r["created_at"] for r in ci), default=None),
    }


def to_markdown(result):
    pr, ci = result["prs"], result["ci"]
    lines = [
        f"## GitHub 지표 ({result['range']})",
        "",
        "### 작업 PR (승격·역반영 PR 제외)",
        "",
        "| 지표 | 값 |",
        "|---|---|",
        f"| 머지된 작업 PR | {pr['work_prs']} |",
        f"| 유형별 | {', '.join(f'{k} {v}' for k, v in sorted(pr['by_type'].items()))} |",
        f"| fix 비율 (fix / feat+fix+refactor) | {pr['fix_ratio_pct']}% |",
        f"| PR 당 커밋 수 (중앙값) | {pr['median_commits_per_pr']} |",
        f"| 첫 커밋 → 머지 (중앙값) | {pr['median_lead_time_hours']} 시간 |",
        f"| 변경 파일 / 라인 (중앙값) | {pr['median_changed_files']} / {pr['median_changed_lines']} |",
        "",
        f"### CI (`{CI_WORKFLOW}`, 첫 실행 {ci['first_run_at']})",
        "",
        "| 단계 | 실행 | 성공률 | 최초 통과율 (표본) | 소요 시간 중앙값 |",
        "|---|---|---|---|---|",
    ]
    for label, key in (("PR 검사", "pull_request"), ("Merge Queue", "merge_group")):
        s = ci[key]
        lines.append(
            f"| {label} | {s['runs']} | {s['success_rate_pct']}% | {s['first_pass_rate_pct']}% ({s['first_pass_sample']}) "
            f"| {s['median_duration_min']} 분 |"
        )
    lines += [
        "",
        f"- 실패한 job: {', '.join(f'{k} {v}' for k, v in ci['failed_jobs'].items()) or '없음'}",
        f"- 취소된 실행 (같은 PR 재 push): {ci['cancelled_runs']}",
    ]
    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--since", help="이 날짜(포함) 이후 (YYYY-MM-DD, UTC)")
    parser.add_argument("--until", help="이 날짜(제외) 이전 (YYYY-MM-DD, UTC)")
    args = parser.parse_args()
    since = datetime.fromisoformat(args.since).replace(tzinfo=timezone.utc) if args.since else None
    until = datetime.fromisoformat(args.until).replace(tzinfo=timezone.utc) if args.until else None

    repo = repo_name()
    result = {
        "repo": repo,
        "range": f"{args.since or '처음'} ~ {args.until or '현재'}",
        "collected_at": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "prs": pr_metrics(fetch_prs(repo), since, until),
        "ci": ci_metrics(repo, fetch_runs(repo), since, until),
    }

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    out = OUT_DIR / f"github-{datetime.now().strftime('%Y%m%d')}.json"
    out.write_text(json.dumps(result, ensure_ascii=False, indent=2))
    print(to_markdown(result))
    print(f"\n원본 집계: {out.relative_to(REPO_ROOT)}", file=sys.stderr)


if __name__ == "__main__":
    main()
