# CI (PR 검사)

PR 대상 브랜치에 따라 검사 수준을 나눈다. **CI 는 PR 에서, CD 는 머지 후에** 실행된다.
배포는 [CD.md](CD.md) 를 참고한다.

## 언제 무엇이 도는가

| 시점 | 실행 | 워크플로 |
|---|---|---|
| `feature/*` push | 없음 | — |
| `feature/* → dev` PR | Branch policy · Lint · Build & unit tests (Debug) | `ci.yml` |
| `dev` 머지 | 없음 (TestFlight 는 수동 실행만) | — |
| `dev → staging` PR | Branch policy · Build (Staging) | `ci.yml` |
| `staging` 머지 | TestFlight 외부 테스트 자동 배포 | `testflight.yml` |
| `staging → main` PR | Branch policy · Build (Release) · Verify App Store version | `ci.yml` · `version-check.yml` |
| `main` 머지 | App Store 심사 자동 제출 | `release.yml` |

같은 PR 에 새 커밋을 push 하면 이전 CI 실행은 취소된다.

## 검사 내용

| Job | 내용 |
|---|---|
| **Branch policy** | `staging` 은 `dev` 에서, `main` 은 `staging` 에서 온 PR 만 허용. fork PR 은 두 브랜치로 받지 않는다. |
| **Lint** | (Linux · Docker) SwiftFormat 0.60.1 (`Kkobungdan/` · `Kkobungdan/.swiftformat`) + SwiftLint 0.65.1 (`Kkobungdan/.swiftlint.yml`, error 만 실패). Xcode 빌드 페이즈와 같은 범위·설정. |
| **Build & unit tests (Debug)** | 시뮬레이터 Debug 빌드 + `KkobungdanTests` 실행. dev PR 에서만 돈다. (staging·main 은 dev 를 거친 코드라 다시 돌리지 않는다) |
| **Build (Staging)** | 기기용 Staging 빌드(서명 없음) + 구성 검증 |
| **Build (Release)** | 기기용 Release 빌드(서명 없음) + 구성 검증 |
| **Verify App Store version** | App Store 출시 버전보다 높은지 등 ([CD.md §4](CD.md#4-버전-규칙)) |

### 구성 검증 (`Scripts/ci/verify-build-config.sh`)

빌드된 앱의 Info.plist 로 확인한다.

| 항목 | Staging | Release |
|---|---|---|
| `APP_BUILD_CONFIGURATION` | `Staging` | `Release` |
| API 호스트 | `Secrets.Staging.xcconfig` 값 · 운영 호스트 아님 | `Secrets.Release.xcconfig` 값 · 스테이징 호스트 아님 |
| 앱 이름 | `STG` 포함 | `STG` 없음 |
| ATS 우회(`NSAppTransportSecurity`) | 없음 | 없음 |
| 공통 | Bundle ID · 버전 · `ITSAppUsesNonExemptEncryption = false` | 〃 |

## 시크릿을 쓰지 않는 이유와 방법

PR CI 는 **배포 인증서·배포용 Secrets 를 쓰지 않는다.** (저장소가 public 이고, fork PR 에는 Secrets 가 전달되지 않는다)

- 서명 없이 빌드한다. (`CODE_SIGNING_ALLOWED=NO`)
- `Secrets.*.xcconfig` 는 [`Scripts/ci/write-stub-secrets.sh`](../Scripts/ci/write-stub-secrets.sh) 가 **가짜 값**으로 만든다.
  구성마다 다른 호스트(`debug.ci.invalid`, `staging.ci.invalid`, `release.ci.invalid`)를 넣어,
  각 구성이 **자기 xcconfig 를 읽는지**를 검증한다. 실제 서버 값은 배포 단계(fastlane)에서 다시 검증한다.
- 그래서 로그·아티팩트(테스트 결과)에 민감정보가 없다.

`Version Check` 만 App Store Connect API Key(Repository Secret)를 쓴다. 빌드·서명은 하지 않는다.

## 브랜치 보호에 등록할 Required Status Check

| 브랜치 | Required checks |
|---|---|
| `dev` | `Branch policy` · `Lint` · `Build & unit tests (Debug)` |
| `staging` | `Branch policy` · `Build (Staging)` |
| `main` | `Branch policy` · `Build (Release)` · `Verify App Store version` |

- 각 job 은 **PR 대상 브랜치로만** 실행 여부가 정해지므로, 위 표대로 등록하면 항상 실행되어 결과를 낸다.
- 조건이 맞지 않아 건너뛴 job 은 GitHub 에서 "성공" 으로 보고된다. **다른 브랜치용 job 을 Required 로 등록하지 않는다.**
- check 는 한 번 실행되어야 목록에 나타난다. 각 브랜치로 PR 을 한 번 연 뒤 등록한다.
- job `name` 을 바꾸면 브랜치 보호 설정도 같이 바꿔야 한다.

## 로컬에서 같은 검사 돌리기

```sh
swiftformat --lint --cache ignore Kkobungdan                 # SwiftFormat (CI: 0.60.1)
swiftlint lint --config Kkobungdan/.swiftlint.yml            # SwiftLint  (CI: 0.65.1)
./Scripts/test.sh                                            # 유닛 테스트
```

## 나중에 추가할 것

- 남은 테스트 (추후 추가)

CI 의 SwiftFormat·SwiftLint 버전을 올릴 때는 로컬 버전도 같이 맞춘다. (`ci.yml` 의 `SWIFTFORMAT_VERSION` · `SWIFTLINT_VERSION`)
