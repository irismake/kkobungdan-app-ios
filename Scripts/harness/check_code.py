#!/usr/bin/env python3
"""
변경분에서 프로젝트 규칙 위반을 결정적으로 찾는다. 위반이 있으면 exit 1.

사용:
  python3 Scripts/harness/check_code.py                  # 기준 브랜치(origin/dev) 이후 변경 + 커밋 안 된 변경 · 새 파일
  python3 Scripts/harness/check_code.py --base origin/main
  python3 Scripts/harness/check_code.py --staged         # 커밋하려고 stage 한 변경만 (git pre-commit)
  python3 Scripts/harness/check_code.py --file <경로>     # 파일 하나 (편집 직후 훅)
  … --lint                                              # 바뀐 앱 소스에 SwiftFormat · SwiftLint 도 실행 (CI Lint 와 같은 설정)

추가된 줄 · 새 파일만 본다. 이미 있던 위반은 세지 않는다.
판단이 필요한 것(요구사항 충족 · 설계 적합성 · 동시성 경합)은 검사하지 않는다 → reviewer.
"""
import argparse
import re
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
APP = "Kkobungdan/"
TESTS = "KkobungdanTests/"
CONTRACT_TESTS = ROOT / "KkobungdanTests/OpenAPIContractTests.swift"
PBXPROJ = ROOT / "Kkobungdan.xcodeproj/project.pbxproj"

PRINT_RE = re.compile(r"(?<![\w.])(print|debugPrint|dump)\(")
FONT_RE = re.compile(r"\.font\(")
RESPONSE_DTO_RE = re.compile(r"^\s*(?:public\s+|internal\s+)?struct\s+(\w+ResponseDTO)\b")
DOMAIN_IMPORT_RE = re.compile(r"^\s*import\s+(SwiftUI|UIKit)\b")
DOMAIN_REF_RE = re.compile(r"\b(\w+DTO|HTTPClient|DIContainer|DummyBackendStore)\b")
PRESENTATION_REF_RE = re.compile(r"\b(\w+DTO|HTTPClient)\b")
TOP_DECL_RE = re.compile(r"^(?:@\w+\s+)*(?:private\s+|fileprivate\s+|public\s+|final\s+)*(struct|class|enum|extension|actor|protocol)\s")


def git(*args):
    return subprocess.run(["git", "-C", str(ROOT), *args], capture_output=True, text=True, check=True).stdout


def parse_added(diff):
    """unified diff(-U0) → {경로: [(줄번호, 내용)]}"""
    result, path, line_no = {}, None, 0
    for raw in diff.splitlines():
        if raw.startswith("+++ "):
            path = raw[6:] if raw.startswith("+++ b/") else None
        elif raw.startswith("@@"):
            line_no = int(re.search(r"\+(\d+)", raw).group(1))
        elif raw.startswith("+") and path:
            result.setdefault(path, []).append((line_no, raw[1:]))
            line_no += 1
    return result


def whole_file(path):
    try:
        return [(i, l) for i, l in enumerate((ROOT / path).read_text(errors="ignore").splitlines(), 1)]
    except FileNotFoundError:
        return []


def changes(args):
    """{경로: [(줄번호, 추가된 줄)]}, 새 파일 집합"""
    if args.file:
        rel = str(Path(args.file).resolve().relative_to(ROOT))
        tracked = subprocess.run(["git", "-C", str(ROOT), "ls-files", "--error-unmatch", rel],
                                 capture_output=True).returncode == 0
        if not tracked:
            return {rel: whole_file(rel)}, {rel}
        return parse_added(git("diff", "-U0", "--no-color", "HEAD", "--", rel)), set()
    if args.staged:
        added = parse_added(git("diff", "--cached", "-U0", "--no-color", "--diff-filter=AM", "--", "*.swift"))
        new = set(git("diff", "--cached", "--name-only", "--diff-filter=A").split())
        return added, new
    base = git("merge-base", args.base, "HEAD").strip()
    added = parse_added(git("diff", "-U0", "--no-color", "--diff-filter=AM", base, "--", "*.swift"))
    new = set(git("diff", "--name-only", "--diff-filter=A", base).split())
    for rel in git("ls-files", "--others", "--exclude-standard", "--", "*.swift").split():
        added[rel] = whole_file(rel)
        new.add(rel)
    return added, new


def is_comment(text):
    return text.strip().startswith(("//", "/*", "*"))


def check(added, new):
    out = []

    def report(rule, path, line, message, doc):
        out.append(f"[{rule}] {path}:{line} — {message} (규칙: .harness/rules/{doc})")

    contract = CONTRACT_TESTS.read_text() if CONTRACT_TESTS.exists() else ""
    for path, lines in sorted(added.items()):
        if not path.endswith(".swift"):
            continue
        app = path.startswith(APP)
        presentation = path.startswith((APP + "Presentation/", APP + "Common/Components/"))
        domain = path.startswith(APP + "Domain/")
        for no, text in lines:
            if is_comment(text):
                continue
            if app and PRINT_RE.search(text):
                report("logging", path, no, "print/debugPrint/dump 대신 Logger 를 쓴다", "swift-style.md")
            if presentation and FONT_RE.search(text):
                report("text-style", path, no, ".font(...) 대신 .textStyle(...) 을 쓴다", "swiftui.md")
            if app and "/DTO/" in path and (m := RESPONSE_DTO_RE.match(text)):
                if m.group(1) not in contract:
                    report("contract-test", path, no, f"{m.group(1)} 을 OpenAPIContractTests 에 등록하지 않았다", "api.md")
            if domain and (DOMAIN_IMPORT_RE.match(text) or DOMAIN_REF_RE.search(text)):
                report("layer", path, no, "Domain 이 UI 프레임워크 · Data 계층을 참조한다", "architecture.md")
            if presentation and PRESENTATION_REF_RE.search(text):
                report("layer", path, no, "Presentation 이 DTO · HTTPClient 를 직접 쓴다", "architecture.md")
        if app and any("#Preview" in t for _, t in lines):
            seen = False
            for no, text in whole_file(path):
                if text.startswith("#Preview"):
                    seen = True
                elif seen and TOP_DECL_RE.match(text):
                    report("preview-placement", path, no, "#Preview 뒤에 다른 선언이 있다", "swiftui.md")
                    break

    project = PBXPROJ.read_text() if PBXPROJ.exists() else ""
    for path in sorted(new):
        if path.startswith(TESTS) and path.endswith(".swift") and f"/* {Path(path).name} in Sources */" not in project:
            report("test-registration", path, 1,
                   "테스트 타깃에 등록되지 않아 실행되지 않는다 → python3 Scripts/harness/add_test_file.py " + path,
                   "testing.md")
    return out


def lint(paths):
    """CI Lint 와 같은 설정. 도구가 없으면 건너뛴다 (CI 가 다시 검사한다)."""
    files = [str(ROOT / p) for p in paths if p.startswith(APP) and p.endswith(".swift") and (ROOT / p).exists()]
    if not files:
        return []
    out = []
    if shutil.which("swiftformat"):
        r = subprocess.run(["swiftformat", "--lint", "--cache", "ignore", *files],
                           cwd=ROOT, capture_output=True, text=True)
        if r.returncode != 0:
            out += [f"[swiftformat] {l.replace(str(ROOT) + '/', '')}" for l in (r.stdout + r.stderr).splitlines()
                    if ": warning:" in l or ": error:" in l]
    else:
        print("swiftformat 이 없어 건너뜀 (CI 에서 검사)", file=sys.stderr)
    if shutil.which("swiftlint"):
        r = subprocess.run(["swiftlint", "lint", "--quiet", "--no-cache", "--config", "Kkobungdan/.swiftlint.yml", *files],
                           cwd=ROOT, capture_output=True, text=True)
        out += [f"[swiftlint] {l}" for l in r.stdout.splitlines() if ": error:" in l]
    else:
        print("swiftlint 이 없어 건너뜀 (CI 에서 검사)", file=sys.stderr)
    return out


def default_base():
    for ref in ("origin/dev", "dev"):
        if subprocess.run(["git", "-C", str(ROOT), "rev-parse", "--verify", "-q", ref], capture_output=True).returncode == 0:
            return ref
    return "HEAD"


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--base")
    mode.add_argument("--staged", action="store_true")
    mode.add_argument("--file")
    parser.add_argument("--lint", action="store_true")
    args = parser.parse_args()
    if not (args.staged or args.file):
        args.base = args.base or default_base()

    added, new = changes(args)
    problems = check(added, new)
    if args.lint:
        problems += lint(sorted(set(added) | new))
    if problems:
        print("규칙 위반:")
        for p in problems:
            print(f"  {p}")
        sys.exit(1)
    scope = "stage 된 변경" if args.staged else args.file or f"{args.base} 이후 변경"
    print(f"코드 검사 통과 ({scope}, Swift 파일 {len([p for p in added if p.endswith('.swift')])}개)")


if __name__ == "__main__":
    main()
