---
paths:
  - ".github/**"
  - "Scripts/ci/**"
  - "fastlane/**"
  - "docs/Deployment/CI.md"
  - "docs/Deployment/CD.md"
  - "Gemfile"
  - "Gemfile.lock"
  - "Kkobungdan.xcodeproj/project.pbxproj"
  - "Kkobungdan/Info.plist"
  - "Kkobungdan/GoogleService-Info.plist"
  - "Kkobungdan/Secrets.example.xcconfig"
---

# CI/CD · 브랜치 정책

세부 내용은 `docs/Deployment/CI.md` · `docs/Deployment/CD.md` 가 원본이다. 바꾸면 문서도 같이 고친다.

## 브랜치 · 머지

- 흐름: `feature/*` → `dev`(**Squash**) → `staging`(**Merge commit**) → `main`(**Merge commit**). 머지는 Merge Queue 를 거친다 (hotfix 역반영 PR 만 우회 머지).
- hotfix: `hotfix/*` (main 에서 분기, 커밋 1개) → `main`. 머지 후 자동으로 열리는 `main → dev` 역반영 PR 은 반드시 **Merge commit** 으로 머지한다. 승격 · 역반영을 Squash 로 제안하지 않는다 (이력이 갈라져 다음 승격 PR 이 막힌다).
- 머지 = 배포다: staging 머지 → TestFlight, main 머지 → App Store 심사 제출 (심사 승인 후 출시는 App Store Connect 에서 수동). **main PR 머지가 곧 배포 승인**이라 GitHub 승인 단계가 따로 없다. **사용자 승인 없이 머지 · 배포 · 워크플로 수동 실행을 하지 않는다.**
- 수동 TestFlight 배포는 dev · staging · `hotfix/*` 에서만 (`docs/Deployment/CD.md`).

## 지켜야 할 것

- Required check 이름(`Branch policy` · `Lint` · `Unit tests (Debug)` · `Build (Staging)` · `Build (Release)` · `Verify App Store version`)은 브랜치 보호에 등록돼 있다. job `name` 을 바꾸면 보호 설정도 바꿔야 한다.
- CI 는 배포용 Secret 을 쓰지 않는다 (가짜 xcconfig, 서명 없음). CD 로그에 Secret 이 찍히지 않게 `::add-mask::` 처리를 유지한다.
- Staging 과 Release 는 **같은 Bundle ID `com.kkobungdan.Kkobungdan`** 를 쓴다. TestFlight 빌드가 기존 꼬붕단 App Store Connect 앱 레코드에 붙어야 하기 때문이다 (같은 기기 동시 설치 불가는 감수). Bundle ID · 앱 레코드 · match 프로필 · `GoogleService-Info.plist` 는 하나로 유지하고, 서버는 `Secrets.<구성>.xcconfig`, 이름은 `APP_DISPLAY_NAME`("꼬붕단 STG")으로만 나눈다. `.staging` Bundle ID 분리를 제안하지 않는다.
- 릴리스 태그 · GitHub Release 는 자동으로 만들지 않고 (출시 후 수동), 태그를 필수로 검증하는 단계도 두지 않는다.
- SwiftFormat · SwiftLint 버전을 올리면 `ci.yml` 과 로컬 버전을 같이 맞춘다.
