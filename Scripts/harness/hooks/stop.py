#!/usr/bin/env python3
"""
Claude Code Stop 훅. 응답을 끝내기 전에 작업 브랜치 변경분 전체를 결정적으로 검사한다.

  - Scripts/harness/verify.sh 와 같은 검사 (규칙 일치 + 코드 규칙 + SwiftFormat · SwiftLint)
  - 위반이 있으면 한 번 막고(decision: block) 이유를 Claude 에게 돌려준다. 같은 응답에서 두 번째는 막지 않는다
    (stop_hook_active) — 고치지 못한 위반은 사용자에게 보고하게 한다.
  - 테스트 · 빌드는 돌리지 않는다 (느림). TDD 단계의 테스트는 스킬이, 최종 빌드 · 테스트는 CI 가 맡는다.
"""
import json
import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]


def run(*args):
    return subprocess.run([sys.executable, *args], cwd=ROOT, capture_output=True, text=True,
                          env={**os.environ, "HARNESS_SOURCE": "claude-stop"})


def main():
    data = json.load(sys.stdin)
    if data.get("stop_hook_active"):
        return
    results = [
        run(str(ROOT / "Scripts/harness/check_rules.py")),
        run(str(ROOT / "Scripts/harness/check_code.py"), "--lint"),
    ]
    failed = [r for r in results if r.returncode != 0]
    if not failed:
        return
    report = "\n".join((r.stdout + r.stderr).strip() for r in failed)
    print(json.dumps({
        "decision": "block",
        "reason": "[하네스] 작업 브랜치 변경분에 규칙 위반이 있습니다. 고치거나, 고치지 않을 이유를 사용자에게 보고하세요.\n" + report,
    }, ensure_ascii=False))


if __name__ == "__main__":
    main()
