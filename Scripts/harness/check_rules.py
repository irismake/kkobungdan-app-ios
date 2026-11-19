#!/usr/bin/env python3
"""
규칙 단일 출처 검사. 문제가 있으면 목록을 출력하고 exit 1.

사용: python3 Scripts/harness/check_rules.py

  1. `.claude/rules` 가 `.harness/rules` 를 가리키는 심볼릭 링크인지 (사본 금지)
  2. 다른 규칙 사본(.codex/rules · .cursor · CURSOR.md)이 남아 있지 않은지
  3. core.md 는 paths 없이 항상 로드, 나머지는 paths 가 있고 각 패턴이 실제 파일에 하나 이상 맞는지 (경로 변경 감지)
  4. AGENTS.md 표가 모든 규칙 파일을 가리키고, 없는 파일을 가리키지 않는지
  5. `.claude/agents` 가 `.harness/agents` 링크이고, 역할 파일마다 name(=파일명) · description · tools 가 있고 AGENTS.md 가 가리키는지
"""
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RULES = ROOT / ".harness/rules"
AGENTS_DIR = ROOT / ".harness/agents"
ALWAYS = {"core.md"}
FORBIDDEN_COPIES = [".codex/rules", ".cursor", "CURSOR.md"]


def glob_regex(pattern):
    out, i = "", 0
    while i < len(pattern):
        if pattern.startswith("**/", i):
            out, i = out + "(?:.*/)?", i + 3
        elif pattern.startswith("**", i):
            out, i = out + ".*", i + 2
        elif pattern[i] == "*":
            out, i = out + "[^/]*", i + 1
        elif pattern[i] == "?":
            out, i = out + "[^/]", i + 1
        else:
            out, i = out + re.escape(pattern[i]), i + 1
    return re.compile(out + "$")


def front_matter_paths(text):
    m = re.match(r"---\n(.*?)\n---\n", text, re.S)
    if not m:
        return None
    return re.findall(r'^\s*-\s*"?([^"\n]+?)"?\s*$', m.group(1), re.M)


def main():
    problems = []
    link = ROOT / ".claude/rules"
    if not link.is_symlink() or link.resolve() != RULES.resolve():
        problems.append(".claude/rules 가 .harness/rules 의 심볼릭 링크가 아닙니다.")
    for p in FORBIDDEN_COPIES:
        if (ROOT / p).exists():
            problems.append(f"규칙 사본이 남아 있습니다: {p}")

    tracked = subprocess.run(["git", "-C", str(ROOT), "ls-files"], capture_output=True, text=True, check=True).stdout.split()
    rule_files = sorted(p.name for p in RULES.glob("*.md"))
    for name in rule_files:
        paths = front_matter_paths((RULES / name).read_text())
        if name in ALWAYS:
            if paths:
                problems.append(f"{name}: 항상 로드되는 규칙에 paths 가 있습니다.")
            continue
        if not paths:
            problems.append(f"{name}: paths 가 없습니다. (항상 로드할 규칙은 core.md 에 둔다)")
            continue
        for pattern in paths:
            if not any(glob_regex(pattern).match(f) for f in tracked):
                problems.append(f"{name}: paths '{pattern}' 에 맞는 파일이 없습니다.")

    agents = (ROOT / "AGENTS.md").read_text()
    referenced = set(re.findall(r"\.harness/rules/([\w.-]+\.md)", agents))
    for name in rule_files:
        if name not in referenced:
            problems.append(f"AGENTS.md 가 {name} 을 가리키지 않습니다.")
    for name in sorted(referenced - set(rule_files)):
        problems.append(f"AGENTS.md 가 없는 규칙 파일을 가리킵니다: {name}")

    agents_link = ROOT / ".claude/agents"
    if not agents_link.is_symlink() or agents_link.resolve() != AGENTS_DIR.resolve():
        problems.append(".claude/agents 가 .harness/agents 의 심볼릭 링크가 아닙니다.")
    role_files = sorted(AGENTS_DIR.glob("*.md"))
    for path in role_files:
        m = re.match(r"---\n(.*?)\n---\n", path.read_text(), re.S)
        fields = dict(re.findall(r"^(\w+):\s*(.+)$", m.group(1), re.M)) if m else {}
        for key in ("name", "description", "tools"):
            if key not in fields:
                problems.append(f"agents/{path.name}: frontmatter 에 {key} 가 없습니다.")
        if fields.get("name") and fields["name"] != path.stem:
            problems.append(f"agents/{path.name}: name 이 파일명과 다릅니다 ({fields['name']}).")
        if f".harness/agents/{path.name}" not in agents:
            problems.append(f"AGENTS.md 가 agents/{path.name} 을 가리키지 않습니다.")

    if problems:
        print("규칙 검사 실패:")
        for p in problems:
            print(f"  - {p}")
        sys.exit(1)
    print(f"규칙 검사 통과: 규칙 {len(rule_files)}개 (항상 로드 {len(ALWAYS & set(rule_files))}개) · 역할 {len(role_files)}개")


if __name__ == "__main__":
    main()
