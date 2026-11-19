#!/usr/bin/env bash
#
# 머지 큐에서 앱 빌드·테스트가 필요한 변경이 있는지 판단한다. (ci.yml 의 Changes job)
#   BASE_SHA..HEAD_SHA 사이에 아래 경로가 바뀌었으면 app=true, 아니면 app=false.
#   판단할 수 없으면(커밋을 못 찾는 등) 안전하게 app=true.
#
# 사용: BASE_SHA=<sha> HEAD_SHA=<sha> ./Scripts/ci/detect-app-changes.sh
#
set -euo pipefail

# 빌드·테스트 결과에 영향을 주는 경로
APP_PATHS='^(Kkobungdan/|KkobungdanTests/|Kkobungdan\.xcodeproj/|Scripts/ci/|\.github/workflows/ci\.yml$|\.github/actions/)'

output() {
  echo "app=$1" >> "${GITHUB_OUTPUT:-/dev/stdout}"
  echo "app=$1 — $2"
  [ -n "${GITHUB_STEP_SUMMARY:-}" ] && echo "**Changes**: app=\`$1\` — $2" >> "$GITHUB_STEP_SUMMARY"
  exit 0
}

if [ -z "${BASE_SHA:-}" ] || [ -z "${HEAD_SHA:-}" ] \
  || ! git cat-file -e "${BASE_SHA}^{commit}" 2>/dev/null || ! git cat-file -e "${HEAD_SHA}^{commit}" 2>/dev/null; then
  output true "비교할 커밋을 찾지 못해 빌드·테스트를 실행한다."
fi

changed="$(git diff --name-only "$BASE_SHA" "$HEAD_SHA")"
echo "변경 파일 ($(printf '%s' "$changed" | grep -c . || true)개):"
printf '%s\n' "$changed" | sed 's/^/  /' | head -50

if printf '%s\n' "$changed" | grep -Eq "$APP_PATHS"; then
  output true "앱 코드 변경 있음 → 빌드·테스트 실행"
fi
output false "앱 코드 변경 없음 → macOS 빌드·테스트 생략"
