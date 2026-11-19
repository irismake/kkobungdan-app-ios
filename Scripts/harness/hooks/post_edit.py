#!/usr/bin/env python3
"""
Claude Code PostToolUse 훅 (Edit · Write). 방금 고친 Swift 파일 하나를 바로 검사한다.
위반이 있으면 exit 2 + stderr 로 Claude 에게 알려 그 자리에서 고치게 한다. (파일 하나라 1~2초)
"""
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]


def main():
    data = json.load(sys.stdin)
    path = (data.get("tool_input") or {}).get("file_path") or ""
    if not path.endswith(".swift"):
        return
    try:
        rel = Path(path).resolve().relative_to(ROOT)
    except ValueError:
        return
    if not str(rel).startswith(("Kkobungdan/", "KkobungdanTests/")):
        return
    result = subprocess.run(
        [sys.executable, str(ROOT / "Scripts/harness/check_code.py"), "--file", str(rel), "--lint"],
        cwd=ROOT, capture_output=True, text=True,
    )
    if result.returncode != 0:
        print(f"[하네스] {rel} 검사 결과 — 고친 뒤 계속하세요.\n{result.stdout}{result.stderr}", file=sys.stderr)
        sys.exit(2)


if __name__ == "__main__":
    main()
