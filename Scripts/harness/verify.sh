#!/usr/bin/env bash
# 작업을 마치기 전 결정적 검증 (수 초). Claude 는 Stop 훅이 같은 검사를 자동으로 돌린다. Codex · 사람은 직접 실행한다.
# 빌드 · 전체 테스트는 넣지 않는다 — 오래 걸리고 CI Merge Queue 가 Debug · Staging · Release 빌드와 테스트를 한다.
#
# 사용: Scripts/harness/verify.sh                       # 규칙 일치 + 코드 규칙 + SwiftFormat · SwiftLint (origin/dev 이후 변경)
#       Scripts/harness/verify.sh --base origin/main    # hotfix 등 기준 브랜치 지정
set -euo pipefail
cd "$(dirname "$0")/../.."
export HARNESS_SOURCE="${HARNESS_SOURCE:-verify}"

python3 Scripts/harness/check_rules.py
python3 Scripts/harness/check_code.py --lint "$@"
