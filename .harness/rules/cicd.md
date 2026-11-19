---
paths:
  - ".github/**"
  - "Scripts/ci/**"
  - "fastlane/**"
  - "docs/CI.md"
  - "docs/CD.md"
  - "Gemfile"
  - "Gemfile.lock"
  - "Kkobungdan.xcodeproj/project.pbxproj"
---

# CI/CD · 브랜치 정책

세부 내용은 `docs/CI.md` · `docs/CD.md` 가 원본이다. 바꾸면 문서도 같이 고친다.

## 브랜치 · 머지

- 흐름: `feature/*` → `dev`(**Squash**) → `staging`(**Merge commit**) → `main`(**Merge commit**). 머지는 Merge Queue 를 거친다 (hotfix 역반영 PR 만 우회 머지).
- hotfix: `hotfix/*` (main 에서 분기, 커밋 1개) → `main`. 머지 후 자동으로 열리는 `main → dev` 역반영 PR 은 반드시 **Merge commit** 으로 머지한다. 승격 · 역반영을 Squash 로 제안하지 않는다 (이력이 갈라져 다음 승격 PR 이 막힌다).
- 머지 = 배포다: staging 머지 → TestFlight, main 머지 → App Store 심사 제출. **사용자 승인 없이 머지 · 배포 · 워크플로 수동 실행을 하지 않는다.**

## 지켜야 할 것

- Required check 이름(`Branch policy` · `Lint` · `Unit tests (Debug)` · `Build (Staging)` · `Build (Release)` · `Verify App Store version`)은 브랜치 보호에 등록돼 있다. job `name` 을 바꾸면 보호 설정도 바꿔야 한다.
- CI 는 배포용 Secret 을 쓰지 않는다 (가짜 xcconfig, 서명 없음). CD 로그에 Secret 이 찍히지 않게 `::add-mask::` 처리를 유지한다.
- Staging 과 Release 는 **같은 Bundle ID** 를 쓴다. 서버는 `Secrets.<구성>.xcconfig`, 이름은 `APP_DISPLAY_NAME` 으로만 나눈다. `.staging` Bundle ID 분리를 제안하지 않는다.
- 릴리스 태그 · GitHub Release 는 자동으로 만들지 않는다 (출시 후 수동).
- SwiftFormat · SwiftLint 버전을 올리면 `ci.yml` 과 로컬 버전을 같이 맞춘다.
