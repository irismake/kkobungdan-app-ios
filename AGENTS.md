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
| 더미 백엔드 | `Data/Common/Dummy/` · `Test*RepositoryImpl` · `DIContainer` | [`dummy-backend.md`](.harness/rules/dummy-backend.md) |
| 비동기 · 동시성 | `Data/` · `*ViewModel.swift` · `Common/Token/` · `AppDelegate` | [`concurrency.md`](.harness/rules/concurrency.md) |
| 테스트 · TDD | `KkobungdanTests/` · `Scripts/test.sh` | [`testing.md`](.harness/rules/testing.md) |
| CI/CD · 브랜치 · 배포 · Xcode 프로젝트 설정 | `.github/` · `Scripts/ci/` · `fastlane/` · `project.pbxproj` | [`cicd.md`](.harness/rules/cicd.md) |

각 규칙 파일 맨 위 `paths` 가 정확한 대상 경로다. (Claude Code 는 이 값으로 자동 로드한다)

Codex 전용 규칙은 현재 없다. 생기면 이 파일에만 적는다.
