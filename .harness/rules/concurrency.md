---
paths:
  - "Kkobungdan/Data/**"
  - "Kkobungdan/Presentation/**/*ViewModel.swift"
  - "Kkobungdan/Common/Token/**"
  - "Kkobungdan/Common/Notification/**"
  - "Kkobungdan/AppDelegate.swift"
  - "Kkobungdan/KkobungdanApp.swift"
---

# Swift Concurrency

## 프로젝트 설정 (`project.pbxproj`)

- 앱 타깃: Swift 5 언어 모드, `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, Approachable Concurrency. **별도 표시가 없는 타입 · 함수는 MainActor 격리**다. 테스트 타깃은 기본 격리가 없다.
- 컴파일러가 Swift 6 수준으로 데이터 경합을 잡지 않는다. 아래 규칙을 직접 지킨다.

## 규칙

- 비동기는 `async/await` 로 쓴다. `DispatchQueue` · completion handler · Combine 을 새로 들이지 않는다.
- 여러 Task 가 공유하는 가변 상태는 `actor` 로 감싼다 (예: `TokenRefreshHandler`, `DummyBackendStore`, `Test*RepositoryImpl`). Repository 프로토콜은 `Sendable`.
- **actor 재진입 주의**: actor 메서드 안의 `await` 사이에 다른 호출이 끼어든다. "확인 후 실행" 을 `await` 너머로 나누지 않는다. 같은 작업을 한 번만 하려면 진행 중인 `Task` 를 저장해 공유한다 (`TokenRefreshHandler.inflightTask` 패턴).
- 시스템 콜백 등 MainActor 밖에서 불리는 메서드만 `nonisolated` 로 표시한다 (`AppDelegate` 참고). `@unchecked Sendable` 은 테스트 대역 외에는 쓰지 않는다.
- 화면 진입 시 로드는 `.task` / `.task(id:)`, 버튼 액션은 `Task { await viewModel.xxx() }`. 화면 이탈 · id 변경으로 취소된 요청은 오류로 보여 주지 않는다 (`error.isCancellation`).
