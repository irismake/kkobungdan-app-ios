#!/usr/bin/env bash
# 작업을 마치기 전 결정적 검증. Claude 는 Stop 훅이 quick 을 자동으로 돌린다. Codex · 사람은 직접 실행한다.
#
# 사용: Scripts/harness/verify.sh            # quick: 규칙 일치 + 코드 규칙 + SwiftFormat · SwiftLint (수 초)
#       Scripts/harness/verify.sh full       # quick + 전체 유닛 테스트 (수 분)
#       Scripts/harness/verify.sh quick --base origin/main   # hotfix 등 기준 브랜치 지정
set -euo pipefail
cd "$(dirname "$0")/../.."

mode="${1:-quick}"
[ $# -gt 0 ] && shift

python3 Scripts/harness/check_rules.py
python3 Scripts/harness/check_code.py --lint "$@"
if [ "$mode" = "full" ]; then
  ./Scripts/test.sh
fi
