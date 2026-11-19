---
paths:
  - "KkobungdanTests/**"
  - "Scripts/test.sh"
---

# XCTest · TDD

## 구성

- 대상: `KkobungdanTests` (XCTest, `@testable import Kkobungdan`). 실행: `./Scripts/test.sh <클래스>[/<메서드>]` (작업 중), `./Scripts/test.sh` 전체는 사용자가 요청할 때만. 전체 테스트는 CI 머지 큐(dev · hotfix 의 main)가 Debug 로 실행한다.
- **테스트 타깃은 파일 동기화 그룹이 아니다.** 새 테스트 파일은 `python3 Scripts/harness/add_test_file.py <경로>` 로 `project.pbxproj` 에 등록해야 컴파일된다. 등록하지 않으면 테스트가 실행되지 않은 채 "통과" 로 보인다. (앱 타깃 `Kkobungdan/` 은 폴더 동기화라 등록이 필요 없다)
- 이름: `test_<한국어로_기대_동작>` (예: `test_401_INVALID_TOKEN_이면_갱신하고_원요청을_재시도한다`). 파일 맨 위 주석에 무엇을 고정하는 테스트인지 적는다.
- 네트워크는 `URLProtocol` 스텁으로 대체한다 (`Network/HTTPClientAuthTests.swift` 의 `StubURLProtocol` 참고). `TokenStorage.shared` 를 건드리면 `tearDown` 에서 `clear()` 한다.
- 계약 테스트(`OpenAPIContractTests`)의 픽스처 · lock 은 `Scripts/sync-openapi.py` 가 만든다. 손으로 고치지 않는다.

## TDD (절차는 `feature` · `bugfix` 스킬)

- RED 는 **기대한 이유로** 실패해야 한다. 컴파일 오류 · 등록 누락으로 인한 실패는 RED 가 아니다.
- 버그 수정: 먼저 버그를 재현하는 실패 테스트를 쓰고, 고친 뒤 통과를 확인한다.
- 새 로직(UseCase · ViewModel 상태 · 변환 · 파서 등): 실패하는 테스트 → 최소 구현 → 리팩토링.
- 순수 레이아웃 변경처럼 테스트로 고정할 동작이 없으면 생략할 수 있다. 생략했으면 그렇다고 보고한다.
