#!/usr/bin/env python3
"""
Claude Code PreToolUse 훅. 위험한 명령 · 보호 파일 수정을 막고, 외부에 영향을 주는 동작은 사용자 승인을 요구한다.

  deny : 되돌리기 어렵거나 배포 · 서명 · Secret 에 닿는 동작 (규칙: .harness/rules/core.md · cicd.md)
  ask  : push · PR 생성 · CI/CD · 하네스 자체 변경 → 사용자에게 확인 창
  그 외: 통과 (Claude Code 의 일반 권한 설정을 따른다)
"""
import json
import re
import shlex
import sys

PROTECTED_BRANCHES = {"dev", "staging", "main"}

BASH_DENY = [
    (r"\bgit\s+reset\b[^;&|]*--hard\b", "git reset --hard 는 커밋 안 된 작업을 지운다"),
    (r"\bgit\s+clean\b[^;&|]*\s-[a-zA-Z]*f", "git clean -f 는 추적 안 된 파일을 지운다"),
    (r"\bgit\s+push\b[^;&|]*(\s--force\b|\s--force-with-lease\b|\s-[a-zA-Z]*f\b|\s\+\S)", "강제 push 금지"),
    (r"\bgit\s+push\b[^;&|]*(\s--delete\b|\s-d\b|\s:\S)", "원격 브랜치 삭제 금지"),
    (r"\bgh\s+pr\s+merge\b", "머지는 사용자가 Merge Queue 로 한다"),
    (r"\bgh\s+workflow\s+run\b", "워크플로 수동 실행(배포)은 사용자가 한다"),
    (r"\bgh\s+release\s+(create|delete|edit|upload)\b", "릴리스 · 태그는 출시 후 사용자가 직접 만든다"),
    (r"\bgh\s+secret\b", "GitHub Secret 은 건드리지 않는다"),
    (r"(^|[;&|(]\s*|\bexec\s+)fastlane(\s|$)", "fastlane(배포 · 서명)은 CD 와 사용자만 실행한다"),
    (r"\bxcrun\s+(altool|notarytool)\b", "App Store 업로드는 CD 가 한다"),
]
BASH_ASK = [
    (r"\bgit\s+push\b", "push 는 사용자 승인 후에만"),
    (r"\bgh\s+pr\s+(create|edit|close|ready)\b", "PR 생성 · 변경은 사용자 승인 후에만"),
    (r"\bgh\s+api\b[^;&|]*(-X|--method)\s*(POST|PUT|PATCH|DELETE)\b", "GitHub 설정 · 데이터 변경은 사용자 승인 후에만"),
]
FILE_DENY = [
    (r"(^|/)Secrets(\.[A-Za-z]+)?\.xcconfig$", "실제 키가 든 xcconfig 는 고치지 않는다 (Secrets.example.xcconfig 만 허용)"),
    (r"(^|/)GoogleService-Info\.plist$", "Firebase 설정은 고치지 않는다"),
    (r"\.(p8|p12|cer|mobileprovision)$", "인증서 · 키 파일은 다루지 않는다"),
    (r"(^|/)fastlane/\.env", "fastlane 비밀 설정은 고치지 않는다"),
    (r"(^|/)\.git/", ".git 내부는 직접 고치지 않는다"),
]
FILE_ASK = [
    (r"(^|/)\.github/", "CI/CD 워크플로 변경은 사용자 확인 필요"),
    (r"(^|/)fastlane/", "배포 설정 변경은 사용자 확인 필요"),
    (r"(^|/)Scripts/ci/", "CI 스크립트 변경은 사용자 확인 필요"),
    (r"(^|/)\.claude/settings[^/]*\.json$", "훅 · 권한 설정 변경은 사용자 확인 필요 (하네스 우회 방지)"),
    (r"(^|/)Scripts/harness/", "검증 스크립트 변경은 사용자 확인 필요 (하네스 우회 방지)"),
    (r"(^|/)\.githooks/", "git 훅 변경은 사용자 확인 필요 (하네스 우회 방지)"),
]


def decide(decision, reason):
    print(json.dumps({"hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": decision,
        "permissionDecisionReason": f"[하네스] {reason}",
    }}, ensure_ascii=False))
    sys.exit(0)


def pushes_protected_branch(command):
    """`git push origin dev` · `HEAD:main` 처럼 보호 브랜치를 대상으로 하는지."""
    for segment in re.split(r"[;&|]+", command):
        try:
            tokens = shlex.split(segment)
        except ValueError:
            tokens = segment.split()
        if "push" not in tokens or "git" not in tokens:
            continue
        args = [t for t in tokens[tokens.index("push") + 1:] if not t.startswith("-")]
        for ref in args[1:]:  # 첫 인자는 remote
            if ref.split(":")[-1].removeprefix("refs/heads/") in PROTECTED_BRANCHES:
                return True
    return False


def main():
    data = json.load(sys.stdin)
    tool = data.get("tool_name")
    tool_input = data.get("tool_input") or {}

    if tool == "Bash":
        command = tool_input.get("command", "")
        if pushes_protected_branch(command):
            decide("deny", "보호 브랜치(dev · staging · main)에 직접 push 하지 않는다 — PR · Merge Queue 로만")
        for pattern, reason in BASH_DENY:
            if re.search(pattern, command):
                decide("deny", reason)
        for pattern, reason in BASH_ASK:
            if re.search(pattern, command):
                decide("ask", reason)
    elif tool in {"Edit", "Write", "MultiEdit", "NotebookEdit"}:
        path = tool_input.get("file_path") or tool_input.get("notebook_path") or ""
        if re.search(r"(^|/)Secrets\.example\.xcconfig$", path):
            sys.exit(0)
        for pattern, reason in FILE_DENY:
            if re.search(pattern, path):
                decide("deny", reason)
        for pattern, reason in FILE_ASK:
            if re.search(pattern, path):
                decide("ask", reason)
    sys.exit(0)


if __name__ == "__main__":
    main()
