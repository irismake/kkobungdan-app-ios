# CI (PR 검사 · 머지 직전 빌드·테스트)

**PR 업데이트 시에는 빌드 없는 가벼운 검사**, **머지 요청 시(GitHub Merge Queue)에만 빌드·테스트**를 수행한다.
머지 직전 빌드·테스트가 실패하면 PR 은 큐에서 빠지고 브랜치에 반영되지 않는다.
배포는 [CD.md](CD.md) 를 참고한다.

## 언제 무엇이 도는가

| 대상 브랜치 | PR 생성·push | 머지 요청 (Merge Queue) | 머지 후 (CD) |
|---|---|---|---|
| `dev` | Branch policy · Lint | Unit tests (Debug) — Debug 빌드 + 유닛 테스트 | 없음 |
| `staging` | Branch policy · Lint | Build (Staging) + 설정 검증 | TestFlight 외부 테스트 자동 배포 |
| `main` | Branch policy · Lint · Verify App Store version | Build (Release) + 설정 검증 · Verify App Store version | App Store 심사 자동 제출 |

- `feature/*` push, 브랜치 머지 후에는 CI 가 돌지 않는다.
- 같은 PR 에 새 커밋을 push 하면 이전 PR 검사는 취소된다. 큐 검사는 취소하지 않는다.
- **PR 업데이트 시에는 빌드·테스트를 하지 않는다.** (Linux 러너의 가벼운 검사만)
- 유닛 테스트는 Debug 구성에서만 돈다. (Staging·Release 는 `ENABLE_TESTABILITY` 가 꺼져 있다) `xcodebuild test` 가 Debug 빌드를 먼저 하므로 dev 큐의 "Debug 빌드 + 유닛 테스트" 는 `Unit tests (Debug)` 한 job 이다.
- **유닛 테스트는 dev 큐에서만** 돈다. staging·main 으로 오는 코드는 dev 큐에서 이미 통과했으므로 배포 구성 빌드만 확인한다.

### 머지 흐름

1. PR 을 연다 → PR 검사가 돈다.
2. PR 검사·리뷰가 통과하면 **Merge when ready**(머지 큐에 추가)를 누른다.
3. GitHub 가 "대상 브랜치 최신 상태 + 이 PR" 을 합친 임시 브랜치(`gh-readonly-queue/...`)를 만들고 큐 검사(빌드)를 돌린다.
4. 큐 검사가 통과하면 그 커밋이 대상 브랜치에 반영된다. → staging·main 은 이 push 로 CD 가 시작된다.
5. 큐 검사가 실패하면 PR 이 큐에서 빠지고 대상 브랜치는 그대로다.

### 머지 방식

브랜치 보호(Merge Queue)에서 브랜치별 머지 방식을 강제한다.

```
feature/login ──┐
feature/chat  ──┼─ Squash ──▶ dev
feature/home  ──┘               │
                               │ Merge commit
                               ▼
                            staging
                               │
                               │ Merge commit
                               ▼
                              main
```

| PR | 머지 방식 | 이유 |
|---|---|---|
| `feature/*` → `dev` | **Squash** | 기능 PR 하나 = dev 커밋 하나. 작업 중 커밋이 dev 이력에 남지 않는다. |
| `dev` → `staging` | **Merge commit** | dev 커밋을 그대로 가져와 dev·staging 이력이 이어진다. |
| `staging` → `main` | **Merge commit** | staging 커밋을 그대로 가져와 staging·main 이력이 이어진다. |

> staging·main 을 squash 하면 새 커밋이 생겨 dev 와 이력이 갈라지고, 다음 승격 PR(`dev → staging`, `staging → main`)에서 같은 변경이 충돌로 나타난다. 그래서 승격 PR 은 반드시 Merge commit 이다.

## 검사 내용

| Job | 시점 | 내용 |
|---|---|---|
| **Branch policy** | PR | `staging` 은 `dev` 에서, `main` 은 `staging` 에서 온 PR 만 허용. fork PR 은 두 브랜치로 받지 않는다. |
| **Lint** | PR | (Linux · Docker) SwiftFormat 0.60.1 (`Kkobungdan/` · `Kkobungdan/.swiftformat`) + SwiftLint 0.65.1 (`Kkobungdan/.swiftlint.yml`, error 만 실패). Xcode 빌드 페이즈와 같은 범위·설정. |
| **Unit tests (Debug)** | 큐 (dev) | 시뮬레이터용 Debug 빌드 + `KkobungdanTests` 실행 |
| **Build (Staging)** | 큐 (staging) | 기기용 Staging 빌드, 서명 없음 + 설정 검증 |
| **Build (Release)** | 큐 (main) | 기기용 Release 빌드, 서명 없음 + 설정 검증 |
| **Verify App Store version** | PR · 큐 (main) | App Store 출시 버전보다 높은지 등 ([CD.md §4](CD.md#4-버전-규칙)) |

### 설정 검증 (`Scripts/ci/verify-build-config.sh`)

빌드된 앱의 Info.plist 로 확인한다.

| 항목 | Staging | Release |
|---|---|---|
| `APP_BUILD_CONFIGURATION` | `Staging` | `Release` |
| API 호스트 | `Secrets.Staging.xcconfig` 값 · 운영 호스트 아님 | `Secrets.Release.xcconfig` 값 · 스테이징 호스트 아님 |
| 앱 이름 | `STG` 포함 | `STG` 없음 |
| ATS 우회(`NSAppTransportSecurity`) | 없음 | 없음 |
| 공통 | Bundle ID · 버전 · `ITSAppUsesNonExemptEncryption = false` | 〃 |

## 러너

| 검사 | 러너 |
|---|---|
| Branch policy · Lint · Verify App Store version | `ubuntu-latest` (Xcode 불필요) |
| Unit tests (Debug) · Build (Staging) · Build (Release) | `macos-26` + Xcode 26.0.1 (CD 와 같은 러너) |

> iOS 빌드·테스트는 Xcode 가 필요해 macOS 에서만 돌 수 있다. public 저장소라 Linux·macOS 기본 러너 모두 무료다.
> `macos-15` 는 러너가 배정되지 않고 계속 대기하는 문제가 있어(2026-11-18) `macos-26` 으로 통일했다.

## 시크릿을 쓰지 않는 이유와 방법

CI 는 **배포 인증서·배포용 Secrets 를 쓰지 않는다.** (저장소가 public 이고, fork PR 에는 Secrets 가 전달되지 않는다)

- 서명 없이 빌드한다. (`CODE_SIGNING_ALLOWED=NO`)
- `Secrets.*.xcconfig` 는 [`Scripts/ci/write-stub-secrets.sh`](../Scripts/ci/write-stub-secrets.sh) 가 **가짜 값**으로 만든다.
  구성마다 다른 호스트(`debug.ci.invalid`, `staging.ci.invalid`, `release.ci.invalid`)를 넣어,
  각 구성이 **자기 xcconfig 를 읽는지**를 검증한다. 실제 서버 값은 배포 단계(fastlane)에서 다시 검증한다.
- 그래서 로그·아티팩트(테스트 결과)에 민감정보가 없다.

`Verify App Store version` 만 App Store Connect API Key(Repository Secret)를 쓴다. 빌드·서명은 하지 않는다.

## Required Status Check 가 PR 과 큐 양쪽에서 평가되는 방식

브랜치마다 Required check 목록은 **하나**이고, PR 과 Merge Queue **양쪽에서 모두 결과가 있어야** 한다.

| 브랜치 | Required checks | PR 에서 | 큐에서 |
|---|---|---|---|
| `dev` | `Branch policy` · `Lint` · `Unit tests (Debug)` | Unit tests 는 건너뜀 | Branch policy·Lint 는 건너뜀 |
| `staging` | `Branch policy` · `Lint` · `Build (Staging)` | Build 는 건너뜀 | Branch policy·Lint 는 건너뜀 |
| `main` | `Branch policy` · `Lint` · `Verify App Store version` · `Build (Release)` | Build 는 건너뜀 | Branch policy·Lint 는 건너뜀 (버전 검사는 다시 실행) |

- GitHub 는 **조건 불일치로 건너뛴 job 을 "성공" 으로 보고**한다. 그래서 PR 전용 검사는 큐에서, 큐 전용 빌드·테스트는 PR 에서 건너뛰어도 Required 평가가 끝난다.
- 실제 차단: PR 검사 실패 → 큐에 넣을 수 없다 / 큐 빌드 실패 → PR 이 큐에서 빠지고 브랜치에 반영되지 않는다.
- **다른 브랜치용 job 을 Required 로 등록하지 않는다.** (예: dev 에 `Build (Release)` 를 등록하면 dev 에서는 항상 건너뜀 = 항상 성공이라 아무것도 막지 못한다)
- check 는 한 번 실행되어야 목록에 나타난다. 큐 전용 check(`Unit tests (Debug)`, `Build (...)`)는 큐를 한 번 돌린 뒤에 나타날 수 있다.
- job `name` 을 바꾸면 브랜치 보호 설정도 같이 바꿔야 한다.

## 브랜치 보호 설정

Settings → Branches(또는 Rules → Rulesets) 에서 `dev`, `staging`, `main` 각각:

| 설정 | 값 | 이유 |
|---|---|---|
| Require a pull request before merging | ✅ | 직접 push 금지 (staging·main 은 push 가 곧 배포) |
| Require status checks to pass | ✅ + 위 표의 Required checks | PR·큐 검사 실패 시 머지 차단 |
| Require branches to be up to date | ❌ (끔) | Merge Queue 가 최신 브랜치와 합쳐서 검사하므로 불필요 |
| **Require merge queue** | ✅ | 머지 직전 빌드 검증 |
| └ Merge method | `dev`: **Squash** · `staging`·`main`: **Merge commit** | [머지 방식](#머지-방식) 참고 |
| └ Build concurrency | 1~2 | macOS 러너 동시 사용량 제한 |
| └ Only merge non-failing pull requests | ✅ | |
| └ Status check timeout | 60분 | macOS 러너 대기 + 빌드 시간 |
| Do not allow bypassing the above settings | ✅ (권장) | 관리자도 실패한 검사를 우회해 머지하지 못하게 |
| Restrict who can push | (선택) | 큐만 브랜치에 쓰도록 |

> Merge Queue 는 조직 소유 public 저장소에서 사용할 수 있다.

## 로컬에서 같은 검사 돌리기

```sh
swiftformat --lint --cache ignore Kkobungdan                 # SwiftFormat (CI: 0.60.1)
swiftlint lint --config Kkobungdan/.swiftlint.yml            # SwiftLint  (CI: 0.65.1)
./Scripts/test.sh                                            # 유닛 테스트
```

## 나중에 추가할 것

- 남은 테스트 (추후 추가)

CI 의 SwiftFormat·SwiftLint 버전을 올릴 때는 로컬 버전도 같이 맞춘다. (`ci.yml` 의 `SWIFTFORMAT_VERSION` · `SWIFTLINT_VERSION`)
