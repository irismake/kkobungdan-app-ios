#!/usr/bin/env bash
#
# PR CI 용 Secrets.{Debug,Staging,Release}.xcconfig 를 "가짜 값" 으로 만든다.
#
# PR CI 는 배포용 Secrets(실제 서버 주소·키)를 쓰지 않는다. 대신 구성마다 서로 다른
# 가짜 호스트(*.ci.invalid)를 넣어, 빌드된 앱이 "자기 구성의 xcconfig" 를 읽는지
# (Release → Secrets.Release, Staging → Secrets.Staging) verify-build-config.sh 로 확인한다.
# `.invalid` 는 예약된 TLD 라 실제로 연결되지 않는다.
#
# 사용: ./Scripts/ci/write-stub-secrets.sh          # CI 에서
#       ./Scripts/ci/write-stub-secrets.sh --force  # 로컬에서 기존 파일을 덮어쓸 때 (주의: 실제 키가 지워진다)
#
set -euo pipefail
cd "$(dirname "$0")/../.."

force=false
[ "${1:-}" = "--force" ] && force=true

for config in Debug Staging Release; do
  file="Kkobungdan/Secrets.${config}.xcconfig"
  if [ -e "$file" ] && [ "${CI:-}" != "true" ] && [ "$force" != true ]; then
    echo "❌ $file 이(가) 이미 있습니다. 실제 키를 덮어쓰지 않도록 중단합니다. (덮어쓰려면 --force)" >&2
    exit 1
  fi

  host="$(echo "$config" | tr '[:upper:]' '[:lower:]').ci.invalid"
  cat > "$file" <<EOF
// CI 전용 가짜 값 — Scripts/ci/write-stub-secrets.sh 가 생성. 실제 서버·키 아님.
KAKAO_NATIVE_APP_KEY = 00000000000000000000000000000000
API_BASE_SCHEME = https
API_BASE_HOST = ${host}
DEV_API_BASE_HOST = staging.ci.invalid
DEV_API_DOCS_USER = ci
DEV_API_DOCS_PASSWORD = ci
EOF
  echo "✓ $file (API_BASE_HOST = ${host})"
done
