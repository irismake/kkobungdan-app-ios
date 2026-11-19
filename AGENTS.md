# Kkobungdan iOS — Codex

프로젝트 규칙 원본은 **`.harness/rules/`** 이고 Claude Code 와 같은 파일을 쓴다. Codex 는 이 파일만 자동으로 읽으므로 아래 순서를 따른다.

1. 작업을 시작하기 전에 [`.harness/rules/core.md`](.harness/rules/core.md) 를 읽는다. (항상)
2. 작업 대상 · 유형에 해당하는 규칙만 아래 표에서 골라 추가로 읽는다. 해당하지 않는 규칙은 읽지 않는다.

| 작업 | 주요 대상 | 규칙 |
|---|---|---|
| Swift 코드 전반 (포맷 · 린트 · 로깅) | `*.swift` | [`swift-style.md`](.harness/rules/swift-style.md) |
| 아키텍처 · 계층 · DI · ViewModel | `Domain/` · `Data/` · `*ViewModel.swift` · `Routing/` | [`architecture.md`](.harness/rules/architecture.md) |
| SwiftUI 화면 · 컴포넌트 · 텍스트 스타일 | `Presentation/` · `Common/Components/` | [`swiftui.md`](.harness/rules/swiftui.md) |
| API 연동 · DTO · 오류 · 계약 테스트 | `Data/` · `OpenAPIContractTests` · `Contract/` | [`api.md`](.harness/rules/api.md) |
| 분쟁 · 신고 · 탈퇴 사유 입력 | `Presentation/{Report,Withdraw,MissionAbort}/` · 관련 `Data/` · `Domain/` | [`reason-survey.md`](.harness/rules/reason-survey.md) |
| 더미 백엔드 | `Data/Common/Dummy/` · `Test*RepositoryImpl` · `DIContainer` | [`dummy-backend.md`](.harness/rules/dummy-backend.md) |
| 비동기 · 동시성 | `Data/` · `*ViewModel.swift` · `Common/Token/` · `AppDelegate` | [`concurrency.md`](.harness/rules/concurrency.md) |
| 테스트 · TDD | `KkobungdanTests/` · `Scripts/test.sh` | [`testing.md`](.harness/rules/testing.md) |
| CI/CD · 브랜치 · 배포 · Xcode 프로젝트 설정 | `.github/` · `Scripts/ci/` · `fastlane/` · `project.pbxproj` | [`cicd.md`](.harness/rules/cicd.md) |

## 작업 절차 (`.harness/skills/`)

해당하는 작업이면 시작할 때 그 스킬 파일을 읽고 절차대로 진행한다.

| 작업 | 스킬 |
|---|---|
| 기능 추가 · 변경 · 리팩토링 (TDD) | [`feature`](.harness/skills/feature/SKILL.md) |
| 버그 수정 (재현 테스트 먼저) | [`bugfix`](.harness/skills/bugfix/SKILL.md) |
| 서버 API 스펙 변경 반영 | [`api-sync`](.harness/skills/api-sync/SKILL.md) |
| 커밋 · PR (사용자 요청 시만) | [`pr`](.harness/skills/pr/SKILL.md) |

## 검증

Codex 에는 Claude 훅이 없다. 대신 다음을 직접 지킨다.

- 작업을 마치기 전에 `Scripts/harness/verify.sh` (TDD 스킬을 따랐으면 `verify.sh full`)를 실행하고 통과시킨다.
- 커밋은 git 훅(`.githooks/`)이 다시 검사한다. `--no-verify` 로 우회하지 않는다.
- `core.md` 의 승인 필요 작업 · 보호 파일 목록을 스스로 지킨다 (Claude 는 훅이 막는다: `Scripts/harness/hooks/pre_tool.py`).

## 역할 (`.harness/agents/`)

작업 경로(S · M · L)와 역할은 `core.md` 의 "작업 경로 · 역할" 을 따른다. Codex 는 서브에이전트 없이 다음처럼 수행한다.

- **L 경로 계획**: [`planner.md`](.harness/agents/planner.md) 의 출력 형식대로 계획만 작성해 사용자 승인을 받은 뒤 구현한다.
- **리뷰**: 사용자가 리뷰를 요청하면 [`reviewer.md`](.harness/agents/reviewer.md) 지침을 따른다. 독립 리뷰가 필요하면 구현한 세션이 아니라 **새 세션**에서 요구사항과 기준 ref 만 받아 수행한다.

각 규칙 파일 맨 위 `paths` 가 정확한 대상 경로다. (Claude Code 는 이 값으로 자동 로드한다)

Codex 전용 규칙은 현재 없다. 생기면 이 파일에만 적는다.
