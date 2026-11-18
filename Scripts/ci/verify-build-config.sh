#!/usr/bin/env bash
#
# 빌드된 .app 의 Info.plist 로 빌드 구성 설정이 올바른지 검사한다. (서명·배포 없음)
#
#   Staging : 구성=Staging · Secrets.Staging 의 API 호스트 · 운영 호스트 아님 · 앱 이름에 STG · ATS 우회 없음
#   Release : 구성=Release · Secrets.Release 의 API 호스트 · 스테이징 호스트 아님 · 앱 이름에 STG 없음 · ATS 우회 없음
#   공통    : Bundle ID · 버전 · 암호화 신고(ITSAppUsesNonExemptEncryption=false)
#
# PR CI 에서는 write-stub-secrets.sh 의 가짜 호스트로 "구성 ↔ xcconfig 연결" 을 검증한다.
# 실제 운영/스테이징 서버 값은 배포(fastlane verify_ipa!) 단계에서 다시 검증한다.
# 호스트 값은 출력하지 않는다. (public 로그)
#
# 사용: ./Scripts/ci/verify-build-config.sh <Staging|Release> <Kkobungdan.app 경로>
#
set -euo pipefail
cd "$(dirname "$0")/../.."

config="${1:?구성 이름(Staging|Release)이 필요합니다}"
app="${2:?.app 경로가 필요합니다}"
plist="$app/Info.plist"
[ -f "$plist" ] || { echo "❌ $plist 가 없습니다." >&2; exit 1; }

failures=0
fail() { echo "❌ $1"; failures=$((failures + 1)); }
pass() { echo "✓ $1"; }

plist_value() { /usr/bin/plutil -extract "$1" raw -o - "$plist" 2>/dev/null || true; }
plist_has() { /usr/bin/plutil -extract "$1" raw -o - "$plist" >/dev/null 2>&1; }
xcconfig_value() {
  local file="Kkobungdan/Secrets.$1.xcconfig"
  [ -f "$file" ] || return 0
  sed -nE "s/^[[:space:]]*$2[[:space:]]*=[[:space:]]*(.*[^[:space:]])[[:space:]]*$/\1/p" "$file" | head -1
}

# ── 공통 ──
[ "$(plist_value CFBundleIdentifier)" = "com.kkobungdan.Kkobungdan" ] \
  && pass "Bundle ID" || fail "Bundle ID 가 com.kkobungdan.Kkobungdan 가 아닙니다."

built_with="$(plist_value APP_BUILD_CONFIGURATION)"
[ "$built_with" = "$config" ] \
  && pass "빌드 구성 = $config" || fail "빌드 구성이 '$built_with' 입니다. ($config 기대)"

[ -n "$(plist_value CFBundleShortVersionString)" ] \
  && pass "버전 $(plist_value CFBundleShortVersionString) ($(plist_value CFBundleVersion))" || fail "CFBundleShortVersionString 이 비어 있습니다."

[ "$(plist_value ITSAppUsesNonExemptEncryption)" = "false" ] \
  && pass "암호화 신고 = false" || fail "ITSAppUsesNonExemptEncryption=false 가 없습니다. (TestFlight Missing Compliance)"

plist_has NSAppTransportSecurity \
  && fail "ATS 우회(NSAppTransportSecurity)가 들어 있습니다. Debug 전용이어야 합니다." || pass "ATS 우회 없음"

# ── API 호스트: 자기 구성의 xcconfig 를 읽는지 ──
host="$(plist_value API_BASE_HOST)"
expected="$(xcconfig_value "$config" API_BASE_HOST)"
if [ -z "$host" ]; then
  fail "API_BASE_HOST 가 비어 있습니다."
elif [ -n "$expected" ] && [ "$host" != "$expected" ]; then
  fail "API_BASE_HOST 가 Secrets.$config.xcconfig 값과 다릅니다."
else
  pass "API_BASE_HOST ← Secrets.$config.xcconfig"
fi

display_name="$(plist_value CFBundleDisplayName)"
case "$config" in
  Release)
    staging_host="$(xcconfig_value Release DEV_API_BASE_HOST)"
    [ -n "$staging_host" ] && [ "$host" = "$staging_host" ] \
      && fail "운영 빌드가 스테이징 API 를 바라봅니다." || pass "스테이징 API 아님"
    [[ "$display_name" == *STG* ]] \
      && fail "운영 빌드의 앱 이름($display_name)에 STG 가 있습니다." || pass "앱 이름 = $display_name"
    ;;
  Staging)
    release_host="$(xcconfig_value Release API_BASE_HOST)"
    [ -n "$release_host" ] && [ "$host" = "$release_host" ] \
      && fail "Staging 빌드가 운영 API 를 바라봅니다." || pass "운영 API 아님"
    [[ "$display_name" == *STG* ]] \
      && pass "앱 이름 = $display_name" || fail "Staging 빌드의 앱 이름($display_name)에 STG 가 없습니다."
    ;;
  *)
    fail "알 수 없는 구성: $config (Staging|Release)"
    ;;
esac

if [ "$failures" -gt 0 ]; then
  echo "::error::$config 빌드 구성 검증 실패 ($failures 건)"
  exit 1
fi
echo "✅ $config 빌드 구성 검증 통과"
