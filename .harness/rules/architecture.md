---
paths:
  - "Kkobungdan/Domain/**"
  - "Kkobungdan/Data/**"
  - "Kkobungdan/Presentation/**/*ViewModel.swift"
  - "Kkobungdan/Presentation/Routing/**"
---

# 아키텍처 · 의존성

## 계층과 의존 방향

`Presentation → Domain ← Data`. 기능 단위 폴더(`Proposal`, `Offer`, `Report` …)를 세 계층에 같은 이름으로 둔다.

| 계층 | 위치 · 구성 | 의존 |
|---|---|---|
| Domain | `Domain/<기능>/{Entity, Repository, UseCase}` — 엔티티 struct, `<기능>RepositoryProtocol: Sendable`, `<동작>UseCase` struct(`init(repository:)` + `execute(...)`) | Foundation 만. SwiftUI · UIKit · DTO · `HTTPClient` · `DIContainer` 참조 금지 |
| Data | `Data/<기능>/{DTO, Repository}` — `<기능>Repository`(실 API, `init(client: HTTPClient = .shared)`), `Test<기능>RepositoryImpl`(더미) | Domain 프로토콜을 구현 |
| Presentation | `Presentation/<기능>/` — `<화면>View` + `<화면>ViewModel` | UseCase · 엔티티를 쓴다. DTO · `HTTPClient` 직접 사용 금지 (Repository 는 조립 지점에서만) |

## 조립 (DI)

- 저장소 인스턴스는 `Data/Common/DIContainer.swift` 가 만든다. `isDummy` 로 실 API ↔ `Test*RepositoryImpl` 을 고르고, 앱 전체가 같은 인스턴스를 공유한다.
- ViewModel 은 UseCase 를 생성자로 받는다. UseCase 조립은 `Presentation/Routing/AppRouteFactory`(`make<화면>ViewModel`) · `MainTabView` 같은 상위 View · 프리뷰에서 `DIContainer` 로 한다. 새 화면도 이 중 한 곳에서 조립한다.

## ViewModel

- `@Observable final class`. 로딩 · 오류 상태가 있으면 `LoadableViewModel`(`isLoading` · `errorMessage`)을 채택하고 `withLoading(fallback:)` 으로 감싼다.
- 오류 문구는 `error.userMessage(fallback: "<화면별 문구>")`. 취소(`error.isCancellation`)는 오류로 보여 주지 않는다. 분기는 상태코드가 아니라 `error.isServerError(.<ServerErrorCode>)` 로 한다. (`Data/Common/Error/`)
- 프리뷰용 `static func preview()` 는 `swiftui` 규칙의 프리뷰 위치를 따른다.
