#!/usr/bin/env bash
#
# PR 출발 브랜치 정책 검사. (ci.yml 의 Branch policy job)
#
#   PR 대상   | 허용 출발 브랜치          | 추가 검사
#   ----------|---------------------------|---------------------------------------------------------
#   dev       | 제한 없음                 | (main → dev 역반영 포함)
#   staging   | dev                       |
#   main      | staging                   | main 의 커밋이 모두 staging 에 있어야 한다 (hotfix 역반영 누락 방지)
#   main      | hotfix/*                  | dev 에만 있는 미출시 커밋이 섞이면 안 된다
#
#   staging·main 은 fork PR 을 받지 않는다.
#
# 필요한 환경변수: BASE, HEAD(브랜치 이름), HEAD_SHA, HEAD_REPO, BASE_REPO
# git 이력이 필요하다. (actions/checkout fetch-depth: 0)
#
# 사용: BASE=main HEAD=staging HEAD_SHA=... HEAD_REPO=o/r BASE_REPO=o/r ./Scripts/ci/branch-policy.sh
#
set -euo pipefail

: "${BASE:?}" "${HEAD:?}" "${HEAD_SHA:?}" "${HEAD_REPO:?}" "${BASE_REPO:?}"
REMOTE="${REMOTE:-origin}"

fail() { echo "::error::$1"; exit 1; }

echo "PR: $HEAD → $BASE"

case "$BASE" in
  staging | main) ;;
  *) echo "✓ $BASE 대상 PR 은 출발 브랜치 제한 없음"; exit 0 ;;
esac

[ "$HEAD_REPO" = "$BASE_REPO" ] || fail "$BASE 로는 fork 저장소의 PR 을 받을 수 없습니다."

if [ "$BASE" = "staging" ]; then
  [ "$HEAD" = "dev" ] || fail "staging 으로는 dev 브랜치에서 온 PR 만 머지할 수 있습니다. (현재: $HEAD)"
  echo "✓ dev → staging"
  exit 0
fi

# ── main ──
case "$HEAD" in
  staging)
    # main 에만 있고 staging 에 없는 일반 커밋(머지 커밋 제외)이 있으면 hotfix 가 역반영되지 않은 것이다.
    # (정상 출시 때 main 에만 있는 것은 staging → main 머지 커밋뿐이다)
    missing="$(git rev-list --no-merges "$REMOTE/main" "^$HEAD_SHA")"
    if [ -n "$missing" ]; then
      echo "main 에만 있는 커밋:"
      git log --no-merges --format='  %h %s' "$REMOTE/main" "^$HEAD_SHA"
      fail "main 의 변경(hotfix 등)이 staging 에 역반영되지 않았습니다. main → dev 역반영 PR(Merge commit)을 머지하고 dev → staging 을 거친 뒤 다시 시도하세요."
    fi
    echo "✓ staging → main (main 의 커밋이 모두 staging 에 있음)"
    ;;
  hotfix/*)
    # hotfix 는 main 에서 분기한다. dev 에만 있는 미출시 커밋이 섞이면 안 된다.
    total="$(git rev-list --count "$HEAD_SHA" "^$REMOTE/main")"
    own="$(git rev-list --count "$HEAD_SHA" "^$REMOTE/main" "^$REMOTE/dev")"
    if [ "$total" != "$own" ]; then
      echo "dev 에서 온 커밋:"
      for c in $(git rev-list "$HEAD_SHA" "^$REMOTE/main"); do
        if git merge-base --is-ancestor "$c" "$REMOTE/dev"; then git log -1 --format='  %h %s' "$c"; fi
      done | head -20
      fail "hotfix 브랜치에 dev 의 미출시 커밋이 섞여 있습니다. main 에서 hotfix 브랜치를 다시 만들어 수정만 담으세요."
    fi
    echo "✓ $HEAD → main (hotfix 커밋 ${own}개, dev 커밋 섞이지 않음)"
    ;;
  *)
    fail "main 으로는 staging 또는 hotfix/* 브랜치에서 온 PR 만 머지할 수 있습니다. (현재: $HEAD)"
    ;;
esac
