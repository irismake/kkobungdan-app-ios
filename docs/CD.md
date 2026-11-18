# CD (배포)

꼬붕단 iOS 앱의 TestFlight·App Store 배포 흐름, 규칙, 설정, 문제 해결 방법을 정리한다.
배포는 GitHub Actions + Fastlane 으로 자동화되어 있고, 사람이 하는 일은 **PR 머지**와 **App Store 출시 버튼**뿐이다.
PR 검사는 [CI.md](CI.md) 를 참고한다.

---

## 1. 한눈에 보기

```
feature/* ──PR──▶ dev ──PR──▶ staging ──PR──▶ main
                   │             │              │
                   │             │              └─ 머지 시 App Store 심사 자동 제출
                   │             │                 → 승인 후 App Store Connect 에서 수동 출시
                   │             └─ 머지 시 TestFlight 외부 테스트 자동 배포
                   └─ (자동 배포 없음) 필요하면 TestFlight 외부 테스트 수동 배포
```

| 브랜치 | 자동 배포 | 수동 배포 | 대상 | 서버 |
|---|---|---|---|---|
| `dev` | 없음 | TestFlight 외부 테스트 | `external_app_tester` | 스테이징 |
| `staging` | 머지 시 TestFlight 외부 테스트 | 가능 | `external_app_tester` | 스테이징 |
| `main` | 머지 시 App Store 심사 제출 | 없음 | App Store | 운영 |

- **`main` PR 머지 = 배포 승인**이다. 머지하면 바로 심사에 제출되므로 머지 전에 버전·변경 내용을 확인한다.
- 심사가 승인되어도 **자동 출시되지 않는다.** App Store Connect 에서 직접 출시한다.
- 릴리스 태그(`vX.Y.Z`)와 GitHub Release 는 자동으로 만들지 않는다. **출시 후 수동으로 생성**한다.

---

## 2. 빌드 구성

| 구성 | 용도 | Bundle ID | 앱 이름 | API | 설정 파일 |
|---|---|---|---|---|---|
| Debug | 로컬 개발 | `com.kkobungdan.Kkobungdan` | 꼬붕단 | 개발 | `Secrets.Debug.xcconfig` |
| Staging | TestFlight | `com.kkobungdan.Kkobungdan` | **꼬붕단 STG** | 스테이징 | `Secrets.Staging.xcconfig` |
| Release | App Store | `com.kkobungdan.Kkobungdan` | 꼬붕단 | 운영 | `Secrets.Release.xcconfig` |

- 세 구성 모두 **같은 Bundle ID** 를 쓴다. TestFlight 는 기존 꼬붕단 App Store Connect 앱의 TestFlight 이다.
  - 같은 기기에 운영 앱과 Staging 앱을 **동시에 설치할 수 없다.** TestFlight 빌드를 설치하면 기존 앱을 대체한다.
  - 기기에서는 앱 이름 **"꼬붕단 STG"** 로 Staging 빌드를 구분한다.
- 서버 주소 등은 `Kkobungdan/Secrets.<구성>.xcconfig` 에서 읽는다. 이 파일들은 gitignore 대상이며, 형식은 [`Secrets.example.xcconfig`](../Kkobungdan/Secrets.example.xcconfig) 를 참고한다.
- Firebase 는 운영·스테이징이 같은 프로젝트(`GoogleService-Info.plist`)를 쓴다.

---

## 3. 배포 방법

### 3-1. TestFlight 외부 테스트 (staging)

1. `dev` → `staging` PR 을 만들고, PR 검사가 통과하면 **머지 큐에 추가**한다. (큐에서 Staging 빌드·설정 검증이 통과해야 반영된다 — [CI.md](CI.md))
2. **TestFlight (Staging)** 워크플로가 자동 실행된다. (빌드 + App Store Connect 처리 대기로 30~60분)
3. 빌드가 `external_app_tester` 그룹에 추가되고 **Beta App Review 에 자동 제출**된다.
4. Apple 이 승인하면 외부 테스터에게 자동 배포되고 알림이 간다.
   - 새 버전의 첫 빌드는 심사에 보통 수 시간~1일 걸린다.
   - 같은 버전의 후속 빌드는 심사 없이 바로 승인되는 경우가 많다.

### 3-2. TestFlight 수동 배포 (dev 또는 staging)

Actions → **TestFlight (Staging)** → **Run workflow** → Branch 에서 `dev` 또는 `staging` 선택 → 실행.
다른 브랜치를 고르면 job 이 실행되지 않는다.

### 3-3. App Store 출시 (main)

1. **버전을 올린다.** App Store 에 출시된 버전보다 높아야 한다. (아래 [4. 버전 규칙](#4-버전-규칙))
   - `dev` 에서 `MARKETING_VERSION` 을 올리는 PR 을 먼저 머지하고, staging 으로 TestFlight 검증을 마친다.
2. `staging` → `main` PR 을 만든다.
   - **Version Check** 워크플로의 `Verify App Store version` 체크가 통과해야 머지 큐에 넣을 수 있다.
3. **머지 큐에 추가**한다. 큐에서 Release 빌드·설정 검증과 버전 검사가 다시 통과하면 `main` 에 반영되고, **App Store Release** 워크플로가 자동 실행되어 심사에 제출한다.
4. App Store Connect 에서 심사 결과를 확인한다.
5. 승인되면 App Store Connect → 앱 → 해당 버전 → **"이 버전 출시"** 로 수동 출시한다.
6. 출시 후 릴리스 태그를 수동으로 만든다.
   ```sh
   git checkout main && git pull
   git tag v1.0.3
   git push origin v1.0.3
   ```

---

## 4. 버전 규칙

`MARKETING_VERSION`(예: `1.0.3`)은 `project.pbxproj` 의 값을 쓰며, 모든 구성이 같은 값이어야 한다.

| 상황 | 결과 |
|---|---|
| App Store 출시 버전보다 **낮거나 같음** | ❌ 실패 — 예: 출시 1.0.3 → 1.0.4 이상만 허용 |
| 같은 버전이 **이미 승인됨** (출시 대기 포함) | ❌ 실패 — 승인된 버전에는 새 빌드를 올릴 수 없다 |
| 같은 버전이 **심사 대기·심사 중** (main 만) | ❌ 실패 — 자동으로 취소하지 않는다 |
| 같은 버전이 **준비 중·거절됨** (아직 미출시) | ✅ 허용 — 재빌드·재제출 가능 |
| App Store Connect 조회 실패 | ❌ 실패 |

- 이 검증은 **main PR(Version Check)** 과 **각 배포 시작 시**(TestFlight·App Store) 모두 실행된다.
- 거절된 이전 심사 제출은 main 배포 시 **자동 취소 후 새 빌드로 다시 제출**한다.
- 심사 대기·심사 중인 제출을 새 빌드로 바꾸려면 App Store Connect 에서 기존 제출을 직접 취소한 뒤 워크플로를 재실행한다.

### 버전을 올리는 시점

App Store 에 출시된 버전에는 TestFlight 빌드도 올릴 수 없다. **출시 직후 `dev` 에서 다음 버전으로 올려야** staging TestFlight 배포가 계속 동작한다.

---

## 5. 빌드 번호

- 모든 배포(dev 수동, staging, main)에서 **자동으로 증가**한다. 직접 바꾸거나 커밋할 필요가 없다.
- 번호 = `max(App Store Connect 에 올라간 모든 빌드 번호, 저장소 CURRENT_PROJECT_VERSION) + 1`
  - TestFlight 빌드와 App Store 빌드는 같은 앱이라 번호를 공유한다.
- **재실행:** 이전 실행이 올린 빌드가 App Store Connect 에 있으므로 다음 번호를 쓴다.
- **동시 실행:** 같은 워크플로는 한 번에 하나만 실행된다. TestFlight 와 App Store 배포가 동시에 돌아 번호가 겹치면 업로드가 거절(ITMS-90189)되고, Fastlane 이 번호를 다시 받아 재빌드한다. (최대 3회)
- 저장소의 `CURRENT_PROJECT_VERSION` 은 하한값으로만 쓰인다.

---

## 6. Staging 빌드가 App Store 에 제출되지 않게 하는 장치

1. App Store 제출은 **`main` 의 App Store Release 워크플로에서만** 한다. TestFlight 워크플로에는 제출 단계가 없다.
2. Fastlane `release` lane 은 `main` 브랜치에서만 실행된다.
3. 업로드 직전 **IPA 의 Info.plist 를 검사**한다.
   - 빌드 구성이 `Release` 인지 (`APP_BUILD_CONFIGURATION`)
   - API 가 운영 서버이고 스테이징 호스트가 아닌지
   - 앱 이름에 `STG` 가 없는지
4. 심사에는 **방금 업로드한 빌드 번호만** 제출한다. 같은 버전으로 TestFlight 에 있는 Staging 빌드는 선택되지 않는다.

> ⚠️ App Store Connect 웹에서 사람이 직접 빌드를 고르는 경우는 막을 수 없다. TestFlight 빌드의 "테스트할 내용" 맨 앞에 `[STAGING · 스테이징 서버]` 가 붙어 있으니 수동 제출 시 확인한다.

---

## 7. 워크플로·Fastlane 구성

### GitHub Actions (`.github/workflows/`)

| 파일 | 트리거 | 환경 | 하는 일 |
|---|---|---|---|
| [`testflight.yml`](../.github/workflows/testflight.yml) | `staging` push, 수동(dev·staging) | `staging` | `fastlane beta` |
| [`release.yml`](../.github/workflows/release.yml) | `main` push | `production` | `fastlane release` |
| [`version-check.yml`](../.github/workflows/version-check.yml) | `main` 대상 PR · `main` 머지 큐 | (없음) | `fastlane verify_release_version` |

- 러너: 빌드는 `macos-26` + Xcode 26.6 (iOS SDK 26.5), 버전 검증은 `ubuntu-latest`
- 실패하면 빌드 로그가 아티팩트(`*-build-logs`, 7일 보관)로 올라간다.

### Fastlane lane (`fastlane/Fastfile`)

| lane | 설명 |
|---|---|
| `beta` | Staging 빌드 → IPA 검증 → 업로드 → `external_app_tester` 배포 + Beta App Review 제출 |
| `release` | Release 빌드 → IPA 검증 → 업로드 → 해당 빌드로 App Store 심사 제출 |
| `verify_release_version` | 빌드 없이 버전 규칙만 검증 |
| `test` | 유닛 테스트 (`KkobungdanTests`) |
| `setup_signing` | [로컬 전용] match 인증서·프로필 생성 (이미 있으면 불필요) |

`beta` / `release` 는 CI 전용이다. 서명 설정을 바꾸려고 `project.pbxproj` 를 수정하기 때문에, 로컬에서 실행하면 작업 트리가 바뀐다.

### 서명

- Fastlane **match** (`appstore` 타입) 로 `mobile-signing` 저장소의 인증서·프로필을 **읽기 전용**으로 가져온다.
- 로컬 Xcode 는 기존처럼 Automatic signing 을 쓴다. CI 에서만 match 프로필로 전환한다.

---

## 8. GitHub 설정

### Secrets

| Secret | 위치 | 내용 |
|---|---|---|
| `ASC_KEY_ID` | Repository | App Store Connect API Key ID |
| `ASC_ISSUER_ID` | Repository | App Store Connect API Issuer ID |
| `ASC_KEY_P8` | Repository | `.p8` 파일을 **base64** 인코딩한 값 |
| `MATCH_GIT_URL` | Repository | `mobile-signing` 저장소 **https** 주소 |
| `MATCH_PASSWORD` | Repository | match 암호화 암호 |
| `MATCH_GIT_BASIC_AUTHORIZATION` | Repository | `아이디:PAT` 를 base64 인코딩한 값 (`mobile-signing` 읽기 권한) |
| `SECRETS_STAGING_XCCONFIG` | Environment `staging` | `Secrets.Staging.xcconfig` 를 base64 인코딩한 값 |
| `SECRETS_RELEASE_XCCONFIG` | Environment `production` | `Secrets.Release.xcconfig` 를 base64 인코딩한 값 |
| `BETA_CONTACT_*`, `BETA_DEMO_ACCOUNT_*`, `BETA_REVIEW_NOTES` | Environment `staging` (선택) | 비우면 App Store Connect 의 TestFlight "테스트 정보" 저장값을 쓴다 |

base64 인코딩:

```sh
base64 -i AuthKey_XXXXXXXXXX.p8 | pbcopy
base64 -i Kkobungdan/Secrets.Staging.xcconfig | pbcopy
base64 -i Kkobungdan/Secrets.Release.xcconfig | pbcopy
echo -n "github아이디:PAT" | base64 | pbcopy
```

xcconfig 를 바꾸면 해당 Secret 도 다시 등록해야 CI 에 반영된다.

### Environments

| 환경 | Deployment branches | 승인자 |
|---|---|---|
| `staging` | `dev`, `staging` | 없음 |
| `production` | `main` | **없음** (main 머지가 승인) |

### 브랜치 보호 · 머지 방식

`dev` · `staging` · `main` 모두 PR 필수 + Merge Queue + Required status checks 를 쓴다. (staging·main 은 push 가 곧 배포)
Required checks 목록, 머지 방식(feature→dev Squash, 승격 PR Merge commit) 등 자세한 설정은 [CI.md](CI.md#브랜치-보호-설정) 에 정리되어 있다.

### 로그 보안

저장소가 public 이라 Actions 로그를 누구나 볼 수 있다. 워크플로는 디코딩한 xcconfig 값을 `::add-mask::` 로 가린다. 새 단계를 추가할 때 Secret 값이나 서버 주소를 `echo` 하지 않는다.

---

## 9. TestFlight 외부 테스트 정보

외부 테스트(Beta App Review)에는 App Store Connect → TestFlight → **테스트 정보** 가 채워져 있어야 한다.

- 베타 앱 설명, 피드백 이메일, 개인정보 처리방침 URL
- 심사 연락처 (이름·이메일·전화번호)
- 로그인 정보: 앱이 Apple 로그인을 쓰므로 심사자가 자기 Apple ID 로 로그인할 수 있다. 데모 계정이 필요 없다는 점을 메모에 적는다.
- 심사 메모: "스테이징 서버에 연결된 테스트 빌드" 임을 적는다.

심사자가 **스테이징 서버에 실제로 접속**하므로, 스테이징 서버가 외부에서 접근 가능하고 테스트할 데이터가 있어야 한다.

---

## 10. 문제 해결

| 증상 | 원인 / 조치 |
|---|---|
| `MARKETING_VERSION(...)이 App Store 출시 버전(...) 이하입니다` | `dev` 에서 버전을 올린다. |
| `... 은 이미 승인된 버전입니다` | 출시하거나, App Store Connect 에서 개발자 거절 후 재실행하거나, 버전을 올린다. |
| `App Store 심사 제출이 이미 진행 중입니다` | App Store Connect 에서 기존 제출을 취소한 뒤 워크플로를 재실행한다. |
| `IPA 검증 실패(...)` | 해당 `SECRETS_*_XCCONFIG` Secret 내용이 맞는지, 빌드 구성 설정이 바뀌지 않았는지 확인한다. |
| `Secrets.<구성>.xcconfig 에 ... 가 없습니다` | xcconfig Secret 에 해당 키가 빠졌다. 파일을 고쳐 다시 base64 로 등록한다. |
| `... 브랜치에서만 실행할 수 있습니다` | TestFlight 는 dev·staging, App Store 는 main 에서만 실행된다. |
| match 단계 실패 | `MATCH_*` Secret 값, `mobile-signing` 접근 권한(PAT), 프로필 만료 여부를 확인한다. |
| 서명 단계에서 entitlements 불일치 | 프로필이 Push Notifications · Sign in with Apple 을 포함하지 않는다. `setup_signing` 을 `force: true` 로 다시 만든다. |
| Xcode 선택 단계 실패 · `iOS xx is not installed` · `Unable to find a destination` | 러너 이미지에 그 Xcode 나 해당 iOS 플랫폼·시뮬레이터가 없다. [runner-images](https://github.com/actions/runner-images/tree/main/images/macos) 의 이미지 README 에서 **iOS SDK 와 시뮬레이터 런타임이 함께 설치된** Xcode 를 골라 세 워크플로의 `XCODE_VERSION` 을 같이 바꾼다. |
| TestFlight 빌드가 "Missing Compliance" | Info.plist 의 `ITSAppUsesNonExemptEncryption` 이 빠졌는지 확인한다. |
| Beta App Review 대기 중인데 staging 에 또 머지 | 정상 동작. 이전 빌드는 만료되고 새 빌드가 심사에 제출된다. |
| 대기 중이던 워크플로가 취소됨 | 같은 워크플로가 대기 중일 때 새 실행이 오면 이전 대기 실행이 취소된다. 최신 커밋이 배포된다. |

---

## 11. 로컬에서 필요한 것

배포는 CI 가 하므로 로컬에서 fastlane 을 돌릴 일은 거의 없다. 필요할 때만:

```sh
bundle install                    # fastlane 설치 (Gemfile.lock 버전)
bundle exec fastlane test         # 유닛 테스트
bundle exec fastlane setup_signing  # match 인증서·프로필 생성 (fastlane/.env 필요)
```

`setup_signing` 용 환경변수는 [`fastlane/.env.example`](../fastlane/.env.example) 을 `fastlane/.env` 로 복사해 채운다. (`fastlane/.env` 는 커밋하지 않는다)
