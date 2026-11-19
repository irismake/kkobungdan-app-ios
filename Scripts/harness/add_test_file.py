#!/usr/bin/env python3
"""
새 테스트 파일을 KkobungdanTests 타깃에 등록한다. (테스트 타깃은 폴더 동기화가 아니라 pbxproj 에 파일마다 등록해야 컴파일된다)

사용: python3 Scripts/harness/add_test_file.py KkobungdanTests/Network/FooTests.swift [...]

  - 파일은 먼저 만들어 두어야 한다. 폴더에 맞는 그룹이 없으면 만든다.
  - 이미 등록된 파일은 건너뛴다 (여러 번 실행해도 같다).
  - 끝나면 `plutil -lint` 로 pbxproj 형식을 확인한다.
"""
import hashlib
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PBXPROJ = ROOT / "Kkobungdan.xcodeproj/project.pbxproj"
TARGET = "KkobungdanTests"


def new_id(seed, text):
    for salt in range(100):
        candidate = hashlib.sha1(f"{seed}:{salt}".encode()).hexdigest().upper()[:24]
        if candidate not in text:
            return candidate
    raise RuntimeError("ID 를 만들 수 없습니다.")


def block(text, obj_id):
    """`<id> /* ... */ = { ... };` 객체 본문의 (시작, 끝) 위치."""
    m = re.search(rf"\t\t{obj_id} /\* [^*]* \*/ = \{{\n", text)
    if not m:
        return None
    end = text.index("\n\t\t};\n", m.end())
    return m.start(), end + len("\n\t\t};\n")


def children_of(text, group_id):
    start, end = block(text, group_id)
    body = text[start:end]
    return re.findall(r"\t\t\t\t(\w{24}) /\* ([^*]+) \*/,", body[body.index("children = ("):])


def group_path(text, obj_id):
    found = block(text, obj_id)
    if not found:  # 한 줄짜리 파일 참조 등 그룹이 아닌 항목
        return None
    start, end = found
    body = text[start:end]
    if "isa = PBXGroup;" not in body:
        return None
    m = re.search(r"\n\t\t\tpath = \"?([^\";]+)\"?;", body)
    return m.group(1) if m else None


def insert_child(text, group_id, child_id, name):
    start, end = block(text, group_id)
    body = text[start:end]
    at = body.index("\t\t\t);", body.index("children = ("))
    body = body[:at] + f"\t\t\t\t{child_id} /* {name} */,\n" + body[at:]
    return text[:start] + body + text[end:]


def insert_in_section(text, section, line):
    marker = f"/* End {section} section */"
    return text.replace(marker, line + marker, 1)


def sources_phase(text):
    m = re.search(rf"\t\t(\w{{24}}) /\* {TARGET} \*/ = \{{\n\t\t\tisa = PBXNativeTarget;", text)
    if not m:
        sys.exit(f"{TARGET} 타깃을 찾을 수 없습니다.")
    start, end = block(text, m.group(1))
    phases = re.findall(r"\t\t\t\t(\w{24}) /\* Sources \*/,", text[start:end])
    if len(phases) != 1:
        sys.exit("테스트 타깃의 Sources 단계를 찾을 수 없습니다.")
    return phases[0]


def root_group(text):
    m = re.search(rf"\t\t(\w{{24}}) /\* {TARGET} \*/ = \{{\n\t\t\tisa = PBXGroup;", text)
    if not m:
        sys.exit(f"{TARGET} 그룹을 찾을 수 없습니다.")
    return m.group(1)


def add(text, rel):
    parts = Path(rel).parts
    if len(parts) < 2 or parts[0] != TARGET or not rel.endswith(".swift"):
        sys.exit(f"{TARGET}/ 아래 .swift 파일만 등록할 수 있습니다: {rel}")
    if not (ROOT / rel).is_file():
        sys.exit(f"파일이 없습니다: {rel}")

    group = root_group(text)
    for folder in parts[1:-1]:
        found = next((cid for cid, _ in children_of(text, group) if group_path(text, cid) == folder), None)
        if not found:
            found = new_id(f"group:{rel}:{folder}", text)
            text = insert_in_section(text, "PBXGroup",
                                     f"\t\t{found} /* {folder} */ = {{\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n\t\t\t);\n"
                                     f"\t\t\tpath = {folder};\n\t\t\tsourceTree = \"<group>\";\n\t\t}};\n")
            text = insert_child(text, group, found, folder)
        group = found

    name = parts[-1]
    if any(n == name for _, n in children_of(text, group)):
        print(f"이미 등록됨: {rel}")
        return text
    file_id = new_id(f"file:{rel}", text)
    build_id = new_id(f"build:{rel}", text + file_id)
    text = insert_in_section(text, "PBXFileReference",
                             f"\t\t{file_id} /* {name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; "
                             f"path = {name}; sourceTree = \"<group>\"; }};\n")
    text = insert_in_section(text, "PBXBuildFile",
                             f"\t\t{build_id} /* {name} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_id} /* {name} */; }};\n")
    text = insert_child(text, group, file_id, name)
    phase = sources_phase(text)
    start, end = block(text, phase)
    body = text[start:end]
    at = body.index("\t\t\t);", body.index("files = ("))
    body = body[:at] + f"\t\t\t\t{build_id} /* {name} in Sources */,\n" + body[at:]
    text = text[:start] + body + text[end:]
    print(f"등록: {rel}")
    return text


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    original = PBXPROJ.read_text()
    text = original
    for rel in sys.argv[1:]:
        text = add(text, rel)
    if text == original:
        return
    PBXPROJ.write_text(text)
    lint = subprocess.run(["plutil", "-lint", str(PBXPROJ)], capture_output=True, text=True)
    if lint.returncode != 0:
        PBXPROJ.write_text(original)
        sys.exit(f"pbxproj 형식 오류로 되돌렸습니다: {lint.stdout}{lint.stderr}")


if __name__ == "__main__":
    main()
