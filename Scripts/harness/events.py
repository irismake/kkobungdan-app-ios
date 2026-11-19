"""
하네스 검사 결과를 로컬에 한 줄씩 남긴다 → `.harness/metrics/collect_agents.py` 가 집계한다.

- 남기는 것: 시각 · 실행 위치(source) · 결과 · 규칙 ID · 파일 경로. 명령 내용 · 코드 · Secret 값은 남기지 않는다.
- 환경변수 HARNESS_SOURCE 가 있을 때만 기록한다 (훅 · git 훅 · verify.sh 가 설정). 수동 실행 · CI 는 기록하지 않는다.
- 기록 실패가 검사를 막으면 안 되므로 예외는 삼킨다.
"""
import json
import os
from datetime import datetime, timezone
from pathlib import Path

EVENTS = Path(__file__).resolve().parents[2] / ".harness/metrics/out/hook-events.jsonl"


def record(result, source=None, **fields):
    source = source or os.environ.get("HARNESS_SOURCE")
    if not source or os.environ.get("GITHUB_ACTIONS") == "true":
        return
    try:
        EVENTS.parent.mkdir(parents=True, exist_ok=True)
        line = {"ts": datetime.now(timezone.utc).isoformat(timespec="seconds"), "source": source, "result": result, **fields}
        with open(EVENTS, "a", encoding="utf-8") as f:
            f.write(json.dumps(line, ensure_ascii=False) + "\n")
    except OSError:
        pass
