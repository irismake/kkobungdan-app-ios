# 하네스 5단계 — 자동 검증 · Quality Gate

AI 의 판단에 맡기지 않고 스크립트로 강제할 수 있는 것은 스크립트로 막는다. 같은 검사기를 여러 시점에서 호출해, 한 단계를 우회해도 다음 단계에서 걸리게 한다.

## 검사 시점 (안쪽 → 바깥쪽)

| 시점 | 무엇이 | 대상 | 막는 방식 | 우회 시 |
|---|---|---|---|---|
| 도구 실행 전 | Claude `PreToolUse` 훅 `hooks/pre_tool.py` | 위험 명령 · 보호 파일 · 외부 영향 동작 | deny / 확인 창(ask) | — (Claude 는 우회 불가, 훅 설정 변경도 ask) |
| 편집 직후 | Claude `PostToolUse` 훅 `hooks/post_edit.py` | 방금 고친 Swift 파일 하나 | 결과를 Claude 에게 돌려줌 → 바로 수정 | 종료 훅 · git 훅 |
| 응답 종료 전 | Claude `Stop` 훅 `hooks/stop.py` | 작업 브랜치 변경분 전체 | 한 번 막고 이유 전달 (반복 방지) | git 훅 |
| 작업 완료 | `Scripts/harness/verify.sh` | 규칙 · 코드 · 린트 (수 초, 빌드 · 테스트 없음) | Codex · 사람은 직접 실행, 스킬 마무리 단계 | git 훅 |
| 커밋 | git `pre-commit` · `commit-msg` (`.githooks/`) | stage 된 변경 · 메시지 형식 | 커밋 거부 | `--no-verify` → CI |
| PR · 머지 | 기존 CI `Lint` 에 하네스 검사 2단계 (7단계) + `Branch policy` · Merge Queue 빌드 · 테스트 | PR 변경분 전체 | Required check `Lint` · Merge Queue | 우회 불가 |

Claude · Codex · 사람 모두 git 훅과 CI 를 거친다. Claude 훅은 그보다 앞에서 더 빨리 알려 주는 층이다.

## 결정적 검사 vs AI 판단

| 스크립트로 결정적으로 검사 | AI(reviewer) · 사람이 판단 |
|---|---|
| 위험 명령: `reset --hard` · `clean -f` · 강제 push · 원격 브랜치 삭제 · 보호 브랜치 직접 push · `gh pr merge` · 워크플로 수동 실행 · 릴리스 · `fastlane` · App Store 업로드 → **deny** | 요구사항을 충족했는지 |
| 외부 영향: push · PR 생성 · `gh api` 쓰기 → **ask** | 설계가 기존 구조 · 도메인에 맞는지 |
| 보호 파일: `Secrets*.xcconfig` · `GoogleService-Info.plist` · 인증서 · `fastlane/.env` · `.git/` → **deny** / CI/CD · 훅 설정 · 검증 스크립트 → **ask** | 컴파일러가 못 잡는 데이터 경합 · actor 재진입 |
| 키 · 인증서 · `.env` · `Secrets.*.xcconfig` 커밋, 형식이 확실한 키 · 토큰 값 (`core`) | 오류 처리 · 사용자 문구가 적절한지 |
| 로그 보간 속 인증 정보 이름(token · password · secret · authorization …) (`swift-style`) | |
| `print` · `debugPrint` · `dump` (`swift-style`) | |
| Presentation 의 `.font(...)` (`swiftui`) | 테스트가 동작을 충분히 고정하는지 |
| 계약 테스트에 등록 안 된 새 응답 DTO (`api`) | 네이밍 · 도메인 용어 |
| Domain → SwiftUI · UIKit · DTO · HTTPClient · DIContainer, Presentation → DTO · HTTPClient (`architecture`) | 디자인과 기존 스타일 차이 |
| `#Preview` 뒤 선언 (`swiftui`) | |
| 타깃에 등록 안 된 새 테스트 파일 (`testing`) | |
| SwiftFormat · SwiftLint error (CI 와 같은 버전 · 설정) | |
| 규칙 · 역할 · 스킬 단일 출처 (`check_rules.py`) | |
| 커밋 메시지 `<type>: <요약>` | |
| 빌드 · 유닛 테스트 (CI Merge Queue — 로컬 검증에는 넣지 않음) | |

- 코드 검사는 **추가된 줄 · 새 파일만** 본다. 이미 있던 위반 때문에 지금 작업이 막히지 않는다.
- 규칙 문서와 실제 코드가 다르면 검사를 만들지 않고 규칙 문구를 코드에 맞췄다: Presentation 의 `DIContainer` 사용(상위 View · 프리뷰에서 조립)은 실제 패턴이라 검사에서 뺐다.

## 필수 검사 항목과 막는 곳 (7단계에서 정리)

| 항목 | 이유 | 막는 곳 |
|---|---|---|
| Secret · 개인 키 유출 | 보안 사고 | 편집 훅(보호 파일 deny) · `check_code.py` secret-file · secret-value (편집 · 종료 훅, git pre-commit, PR `Lint`) |
| 민감 정보가 든 환경변수 파일 커밋 | 보안 사고 | `.gitignore` + `check_code.py` secret-file (`git add -f` 로 넣어도 걸림) |
| 인증 토큰 로깅 | 인증 정보 노출 | `check_code.py` logging(print) · sensitive-log(로그 보간 속 인증 정보) |
| 운영 빌드의 서버 환경 오류 | 운영 장애 | 기존: Merge Queue `Build (Staging)` · `Build (Release)` + `Scripts/ci/verify-build-config.sh`, 배포 시 fastlane `verify_ipa!` |
| 빌드 실패 | 앱 실행 불가 | 기존: Merge Queue 빌드 (Debug · Staging · Release) |
| 테스트 실패 | 기존 기능 손상 가능성 | 기존: Merge Queue `Unit tests (Debug)` (dev 큐, main 큐는 hotfix) |

- 아래 셋은 이미 CI 가 Required check 로 막고 있어 새로 만들지 않았다.
- **빌드 · 전체 테스트는 로컬 검증에 넣지 않는다** (오래 걸림). PR push 단계에는 빌드가 없으므로 컴파일 오류는 Merge Queue 에서 처음 드러난다 — 실패하면 브랜치에 반영되지 않는다. TDD 중 해당 테스트 클래스만 돌리는 것은 개발 과정으로 둔다.
- 키 값 검사는 형식이 확실한 것만 본다(개인 키 블록 · GitHub · AWS · Slack · Google · AI API 키). Firebase 클라이언트 설정(`GoogleService-Info.plist`)은 공개 커밋용이라 제외.

## 기존 위반 (이번 단계에서 고치지 않음)

| 위치 | 위반 | 처리 |
|---|---|---|
| `Kkobungdan/Common/Token/TokenStorage.swift:24`, `:54` | `print` 로 access token 출력 (DEBUG) | `99944d5` 에서 수정 (Logger, 상태만 기록) |
| `Kkobungdan/Presentation/Terms/TermsAgreementView.swift:160` | `.font(.system(...))` | `99944d5` 에서 수정 (바텀시트와 같은 `icon_check` 에셋) |

## 검증

| 항목 | 결과 |
|---|---|
| `pre_tool.py` 판정 | ✅ 25개 경우 표 테스트 (deny 13 · ask 6 · allow 6), `cat fastlane/…` 같은 읽기는 통과 |
| Claude 에서 실제 동작 | ✅ 헤드리스 세션에서 `fastlane --version` · `Secrets.Probe.xcconfig` 쓰기가 훅에 막힘 (파일 생성 안 됨) |
| `check_code.py` | ✅ 위반 7종을 넣은 임시 파일로 모두 검출, 정상 상태 통과 |
| `post_edit.py` · `stop.py` | ✅ 위반 시 exit 2 · block, `stop_hook_active` 면 통과, 정상이면 통과 |
| git 훅 | ✅ `commit-msg` 형식 판정, 설치 (`git config core.hooksPath .githooks`) |
| Codex | ⚠️ 훅 없음 → `AGENTS.md` 에 `verify.sh` 실행 지시 + git 훅 · CI 가 차단선 |

## 설치

- Claude 훅: `.claude/settings.json` (레포에 포함, 자동 적용)
- git 훅: 클론마다 한 번 `Scripts/harness/install-git-hooks.sh` (해제: `git config --unset core.hooksPath`)
