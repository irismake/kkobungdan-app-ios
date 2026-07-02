#!/usr/bin/env python3
"""
서버 OpenAPI 스펙을 내려받아 계약 테스트용 산출물을 자동 생성한다.

생성물 (모두 KkobungdanTests/Contract, KkobungdanTests/Fixtures/generated 아래):
  Contract/openapi.json          서버 원본 스펙 (참고용)
  Contract/contract.current.json 정규화 스냅샷 (매 실행 갱신)
  Contract/contract.lock.json    승인된 기준선 (--accept 시에만 갱신)
  Fixtures/generated/<S>.json     스키마별 maximal 예시 (모든 필드)
  Fixtures/generated/<S>.min.json 스키마별 minimal 예시 (required 필드만)

사용:
  python3 Scripts/sync-openapi.py            # 스펙 받아 픽스처/current 갱신
  python3 Scripts/sync-openapi.py --accept   # 추가로 lock 을 current 로 승인
  python3 Scripts/sync-openapi.py --url http://other/openapi.json

워크플로:
  1) 평소엔 인자 없이 실행 → DTO 디코딩 테스트가 최신 스펙으로 돈다.
  2) 계약 테스트가 빨간불이면 diff 를 보고 DTO 를 수정한다.
  3) 변경을 인지·반영했으면 --accept 로 기준선을 갱신한다.
"""
from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import sys
import urllib.parse
import urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CONTRACT_DIR = os.path.join(ROOT, "KkobungdanTests", "Contract")
GENERATED_DIR = os.path.join(ROOT, "KkobungdanTests", "Fixtures", "generated")
# 앱과 동일한 단일 출처. gitignore 된 파일이라 서버 주소를 하드코딩하지 않는다.
SECRETS_XCCONFIG = os.path.join(ROOT, "Kkobungdan", "Secrets.xcconfig")

# date-time 포맷은 DateFormatters.localDateTime ("yyyy-MM-dd'T'HH:mm:ss") 과 맞춘다.
SAMPLE_DATETIME = "2026-06-12T18:00:00"


# ─────────────────────────────── 서버 주소 결정 ──────────────────────────────
# 계약 테스트는 항상 개발/테스트 서버를 기준으로 한다. (실서버 API_BASE_HOST 가 아님)
DEV_HOST_KEY = "DEV_API_BASE_HOST"


def read_dev_api_base_host(path: str):
    """Secrets.xcconfig 에서 `DEV_API_BASE_HOST = ...` 값을 읽는다 (없으면 None)."""
    if not os.path.exists(path):
        return None
    with open(path, encoding="utf-8") as f:
        for line in f:
            m = re.match(rf"\s*{DEV_HOST_KEY}\s*=\s*(\S+)", line)
            if m:
                return m.group(1)
    return None


def openapi_url_from_host(host: str) -> str:
    """host 값에서 OpenAPI 스펙 URL 을 만든다.

    DEV_API_BASE_HOST 는 스킴(`http://`)·경로(`/docs`)가 붙어 있을 수도, 맨 호스트명일
    수도 있다. 스킴/netloc 만 취해 `<scheme>://<netloc>/openapi.json` 으로 정규화한다.
    """
    if not re.match(r"^https?://", host):
        host = "http://" + host
    parts = urllib.parse.urlsplit(host)
    return urllib.parse.urlunsplit((parts.scheme, parts.netloc, "/openapi.json", "", ""))


def resolve_url(cli_url):
    """우선순위: --url > 환경변수 OPENAPI_URL > Secrets.xcconfig 의 DEV_API_BASE_HOST."""
    if cli_url:
        return cli_url
    if os.environ.get("OPENAPI_URL"):
        return os.environ["OPENAPI_URL"]
    host = read_dev_api_base_host(SECRETS_XCCONFIG)
    if host:
        return openapi_url_from_host(host)
    raise SystemExit(
        f"개발 서버 주소를 찾지 못했습니다. 계약 테스트는 실서버가 아닌 {DEV_HOST_KEY} 를 씁니다.\n"
        "다음 중 하나로 지정하세요:\n"
        f"  - Kkobungdan/Secrets.xcconfig 의 {DEV_HOST_KEY} (권장)\n"
        "  - 환경변수 OPENAPI_URL (예: CI 에서 export OPENAPI_URL=http://dev-host/openapi.json)\n"
        "  - --url http://dev-host/openapi.json"
    )


# ─────────────────────────────── 스펙 다운로드 ───────────────────────────────
def fetch(url: str) -> dict:
    with urllib.request.urlopen(url, timeout=20) as resp:
        return json.loads(resp.read().decode("utf-8"))


# ─────────────────────────────── 정규화(스냅샷) ──────────────────────────────
def type_str(meta: dict) -> str:
    if "$ref" in meta:
        return "ref:" + meta["$ref"].split("/")[-1]
    if "anyOf" in meta:
        return "anyOf(" + "|".join(type_str(o) for o in meta["anyOf"]) + ")"
    t = meta.get("type")
    if t == "array":
        return "array<" + type_str(meta.get("items", {})) + ">"
    if t == "string" and "enum" in meta:
        return "enum"
    return t or "unknown"


def normalize(schemas: dict) -> dict:
    out = {}
    for name, s in schemas.items():
        props = s.get("properties", {})
        out[name] = {
            "required": sorted(s.get("required", [])),
            "properties": {k: type_str(m) for k, m in sorted(props.items())},
        }
    return dict(sorted(out.items()))


# ─────────────────────────────── 예시 생성 ───────────────────────────────────
def example_for(meta: dict, schemas: dict, required_only: bool, seen: frozenset):
    if "$ref" in meta:
        return example_for_ref(meta["$ref"], schemas, required_only, seen)
    if "anyOf" in meta:
        non_null = [o for o in meta["anyOf"] if o.get("type") != "null"]
        if non_null:
            return example_for(non_null[0], schemas, required_only, seen)
        return None
    t = meta.get("type")
    if t == "string":
        if "enum" in meta:
            return meta["enum"][0]
        if meta.get("format") in ("date-time", "date"):
            return SAMPLE_DATETIME
        return "string"
    if t == "integer":
        return 0
    if t == "number":
        return 0.0
    if t == "boolean":
        return True
    if t == "array":
        # 배열 요소는 항상 maximal 로 채워 nested DTO 가 디코딩되게 한다.
        return [example_for(meta.get("items", {}), schemas, False, seen)]
    if t == "object":
        return {}
    return None


def example_for_ref(ref: str, schemas: dict, required_only: bool, seen: frozenset):
    name = ref.split("/")[-1]
    if name in seen:  # 순환 참조 방지
        return None
    s = schemas.get(name, {})
    if "enum" in s:
        return s["enum"][0]
    if s.get("type") in ("string", "integer", "number", "boolean"):
        return example_for(s, schemas, required_only, seen)
    return example_for_object(name, schemas, required_only, seen | {name})


def example_for_object(name: str, schemas: dict, required_only: bool, seen: frozenset) -> dict:
    s = schemas.get(name, {})
    props = s.get("properties", {})
    req = set(s.get("required", []))
    out = {}
    for k, meta in props.items():
        if required_only and k not in req:
            continue
        out[k] = example_for(meta, schemas, required_only=False, seen=seen)
    return out


# ─────────────────────── 응답 payload 스키마 추출 ────────────────────────────
# 엔드포인트 2xx 응답에서 ApiResponse_/PageResponse_/list_ 래퍼(data·content)를 벗겨
# 클라이언트가 DTO 로 디코딩해야 할 "실제 payload 스키마"만 골라낸다.
def refs_in(frag: dict) -> list:
    out = []
    if not isinstance(frag, dict):
        return out
    if "$ref" in frag:
        out.append(frag["$ref"].split("/")[-1])
    if "items" in frag:
        out += refs_in(frag["items"])
    for combiner in ("anyOf", "allOf", "oneOf"):
        for o in frag.get(combiner, []):
            out += refs_in(o)
    return out


def collect_payload_leaves(name: str, schemas: dict, seen: frozenset, acc: set) -> None:
    if name in seen:
        return
    seen = seen | {name}
    props = schemas.get(name, {}).get("properties", {})
    inner = []
    for key in ("data", "content"):  # ApiResponse.data / PageResponse.content
        if key in props:
            inner += refs_in(props[key])
    if inner:
        for n in inner:
            collect_payload_leaves(n, schemas, seen, acc)
    elif not (name.startswith("ApiResponse") or name.startswith("PageResponse")):
        # 래퍼인데 payload 가 없으면(빈 응답) 무시, 그 외에는 실제 payload 스키마.
        acc.add(name)


def response_payload_schemas(spec: dict) -> dict:
    """{ payload 스키마명: "GET /path" } — 응답 본문이 있는 엔드포인트만."""
    schemas = spec.get("components", {}).get("schemas", {})
    out = {}
    for path, methods in spec.get("paths", {}).items():
        for method, op in methods.items():
            for code, resp in op.get("responses", {}).items():
                if not str(code).startswith("2"):
                    continue
                sch = resp.get("content", {}).get("application/json", {}).get("schema", {})
                acc: set = set()
                for n in refs_in(sch):
                    collect_payload_leaves(n, schemas, frozenset(), acc)
                for n in acc:
                    out.setdefault(n, f"{method.upper()} {path}")
    return dict(sorted(out.items()))


# ─────────────────────────────── 파일 쓰기 ───────────────────────────────────
def write_json(path: str, obj) -> None:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        json.dump(obj, f, ensure_ascii=False, indent=2)
        f.write("\n")


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--url", default=None, help="OpenAPI 스펙 URL (미지정 시 Secrets.xcconfig/환경변수에서 결정)")
    ap.add_argument("--accept", action="store_true", help="현재 스냅샷을 기준선(lock)으로 승인")
    args = ap.parse_args()

    url = resolve_url(args.url)
    print(f"→ OpenAPI 스펙 다운로드: {url}")
    spec = fetch(url)
    schemas = spec.get("components", {}).get("schemas", {})
    print(f"  스키마 {len(schemas)}개 발견")

    # 1) 원본 스펙
    write_json(os.path.join(CONTRACT_DIR, "openapi.json"), spec)

    # 2) 정규화 스냅샷
    current = normalize(schemas)
    write_json(os.path.join(CONTRACT_DIR, "contract.current.json"), current)

    # 2-1) 응답 payload 스키마 매니페스트 (DTO 누락 감지용)
    payloads = response_payload_schemas(spec)
    write_json(os.path.join(CONTRACT_DIR, "response-schemas.json"), payloads)
    print(f"  응답 payload 스키마 {len(payloads)}개")

    lock_path = os.path.join(CONTRACT_DIR, "contract.lock.json")
    if args.accept or not os.path.exists(lock_path):
        shutil.copyfile(os.path.join(CONTRACT_DIR, "contract.current.json"), lock_path)
        print(f"  기준선(lock) {'승인' if args.accept else '최초 생성'}")

    # 3) 스키마별 maximal / minimal 예시
    if os.path.isdir(GENERATED_DIR):
        shutil.rmtree(GENERATED_DIR)
    for name in schemas:
        if schemas[name].get("type") != "object" and "properties" not in schemas[name]:
            continue  # enum 등 단순 스키마는 픽스처 불필요
        write_json(os.path.join(GENERATED_DIR, f"{name}.json"),
                   example_for_object(name, schemas, required_only=False, seen=frozenset({name})))
        write_json(os.path.join(GENERATED_DIR, f"{name}.min.json"),
                   example_for_object(name, schemas, required_only=True, seen=frozenset({name})))
    print(f"  픽스처 생성 완료 → {os.path.relpath(GENERATED_DIR, ROOT)}")
    print("완료.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
