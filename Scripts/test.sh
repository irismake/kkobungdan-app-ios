#!/usr/bin/env bash
#
# KkobungdanTests(DTO 디코딩 · OpenAPI 계약 테스트)를 실행한다. Xcode 의 ⌘U 와 같다.
# 사용: ./Scripts/test.sh
#
set -euo pipefail
cd "$(dirname "$0")/.."

# 사용 가능한 iPhone 시뮬레이터를 자동으로 하나 고른다. (없으면 에러 메시지)
SIM_NAME=$(
  xcrun simctl list devices available \
    | grep -oE 'iPhone [^(]+' \
    | head -1 \
    | sed 's/[[:space:]]*$//'
)
if [ -z "${SIM_NAME}" ]; then
  echo "❌ 사용 가능한 iPhone 시뮬레이터가 없습니다. Xcode > Settings > Platforms 에서 설치하세요." >&2
  exit 1
fi
echo "▶︎ 시뮬레이터: ${SIM_NAME}"

xcodebuild test \
  -project Kkobungdan.xcodeproj \
  -scheme Kkobungdan \
  -destination "platform=iOS Simulator,name=${SIM_NAME}" \
  -only-testing:KkobungdanTests
