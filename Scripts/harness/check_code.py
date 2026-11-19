#!/usr/bin/env python3
"""
변경분에서 프로젝트 규칙 위반을 결정적으로 찾는다. 위반이 있으면 exit 1.

사용:
  python3 Scripts/harness/check_code.py                  # 기준 브랜치(origin/dev) 이후 변경 + 커밋 안 된 변경 · 새 파일
  python3 Scripts/harness/check_code.py --base origin/main
  python3 Scripts/harness/check_code.py --staged         # 커밋하려고 stage 한 변경만 (git pre-commit)
  python3 Scripts/harness/check_code.py --file <경로>     # 파일 하나 (편집 직후 훅)
  … --lint                                              # 바뀐 앱 소스에 SwiftFormat · SwiftLint 도 실행 (CI Lint 와 같은 설정)

검사: 키 · 인증서 · .env · Secrets xcconfig 커밋 / 키 · 토큰 값 / 로그 속 인증 정보 / print · .font /
      계약 테스트 미등록 DTO / 계층 의존 / 프리뷰 위치 / 테스트 미등록 (+ --lint: SwiftFormat · SwiftLint)
추가된 줄 · 새 파일만 본다. 이미 있던 위반은 세지 않는다.
판단이 필요한 것(요구사항 충족 · 설계 적합성 · 동시성 경합)은 검사하지 않는다 → reviewer.
"""
import argparse
import os
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
# ── 보안 ──────────────────────────────────────────────
# 커밋하면 안 되는 파일 (.gitignore 를 -f 로 우회해 추가하는 경우까지 잡는다)
SECRET_FILE_RE = re.compile(
    r"(\.(p8|p12|pem|key|cer|mobileprovision|jks|keystore)$)"
    r"|((^|/)\.env(\.[\w.-]+)?$)"
    r"|((^|/)Secrets(\.(?!example\.)[A-Za-z]+)?\.xcconfig$)"
)
# 형식이 확실한 키 · 토큰만 (일반 단어 "API_KEY" 같은 매칭은 하지 않는다 → 오탐 방지)
SECRET_VALUE_RES = [
    ("개인 키", re.compile(r"-----BEGIN (RSA |EC |OPENSSH |DSA |ENCRYPTED )?PRIVATE KEY-----")),
    ("GitHub 토큰", re.compile(r"\b(gh[pousr]_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{50,})\b")),
    ("AWS 액세스 키", re.compile(r"\bAKIA[0-9A-Z]{16}\b")),
    ("Slack 토큰", re.compile(r"\bxox[abprs]-[A-Za-z0-9-]{10,}")),
    ("Google API 키", re.compile(r"\bAIza[0-9A-Za-z_-]{35}\b")),
    ("AI API 키", re.compile(r"\bsk-(ant-)?[A-Za-z0-9_-]{32,}")),
]
# 공개로 커밋하도록 설계된 값이 들어 있는 파일 (Firebase 클라이언트 설정)
SECRET_VALUE_ALLOW = re.compile(r"(^|/)GoogleService-Info\.plist$")
# 로그 호출 안의 문자열 보간에 인증 정보 이름이 들어가는지
LOG_CALL_RE = re.compile(r"(\b\w*[Ll]ogger\.(debug|info|notice|warning|error|fault|trace|critical|log)|\bNSLog|(?<![\w.])(print|debugPrint|dump))\(")
INTERPOLATION_RE = re.compile(r"\\\(([^)]*)\)")
SENSITIVE_NAME_RE = re.compile(r"(?i)(token|password|passwd|secret|authorization|cookie|credential|apikey|api_key)")
# OSLog 가 기기 로그에서 값을 가리는 보간은 허용한다 (예: FCM 토큰)
MASKED_RE = re.compile(r"privacy:\s*\.(private|sensitive)")
MAX_SCAN_BYTES = 2_000_000

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
    file = ROOT / path
    try:
        if file.stat().st_size > MAX_SCAN_BYTES:
            return []
        return [(i, l) for i, l in enumerate(file.read_text(errors="ignore").splitlines(), 1)]
    except (FileNotFoundError, IsADirectoryError):
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
        added = parse_added(git("diff", "--cached", "-U0", "--no-color", "--diff-filter=AM"))
        new = set(git("diff", "--cached", "--name-only", "--diff-filter=A").split())
        return added, new
    base = git("merge-base", args.base, "HEAD").strip()
    added = parse_added(git("diff", "-U0", "--no-color", "--diff-filter=AM", base))
    new = set(git("diff", "--name-only", "--diff-filter=A", base).split())
    for rel in git("ls-files", "--others", "--exclude-standard").split():
        added[rel] = whole_file(rel)
        new.add(rel)
    return added, new


def is_comment(text):
    return text.strip().startswith(("//", "/*", "*"))


def check(added, new):
    out = []

    def report(rule, path, line, message, doc):
        out.append(f"[{rule}] {path}:{line} — {message} (규칙: .harness/rules/{doc})")
        if os.environ.get("GITHUB_ACTIONS") == "true":  # PR 화면의 해당 줄에 표시
            print(f"::error file={path},line={line},title=하네스 {rule}::{message} (.harness/rules/{doc})")

    for path in sorted(new):
        if SECRET_FILE_RE.search(path):
            report("secret-file", path, 1, "키 · 인증서 · 환경변수 · Secrets xcconfig 파일은 커밋하지 않는다", "core.md")

    contract = CONTRACT_TESTS.read_text() if CONTRACT_TESTS.exists() else ""
    for path, lines in sorted(added.items()):
        if not SECRET_VALUE_ALLOW.search(path):
            for no, text in lines:
                for label, pattern in SECRET_VALUE_RES:
                    if pattern.search(text):
                        report("secret-value", path, no, f"{label}로 보이는 값이 들어 있다 — 제거하고 키를 폐기 · 재발급한다", "core.md")
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
            if app and LOG_CALL_RE.search(text) and any(
                    SENSITIVE_NAME_RE.search(expr) and not MASKED_RE.search(expr)
                    for expr in INTERPOLATION_RE.findall(text)):
                report("sensitive-log", path, no, "토큰 · 비밀번호 등 인증 정보를 로그에 넣지 않는다 (상태만 남긴다)", "swift-style.md")
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
