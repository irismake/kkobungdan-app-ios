---
paths:
  - "Kkobungdan/Data/Common/Dummy/**"
  - "Kkobungdan/Data/**/Test*RepositoryImpl.swift"
  - "Kkobungdan/Data/Common/DIContainer.swift"
---

# 더미 백엔드 (`DummyBackendStore`)

더미 모드(`DIContainer.isDummy`)에서 `DummyBackendStore`(actor)는 실제 백엔드의 **단일 DB + 트랜잭션 cascade** 역할만 한다.

- **store 에만 둔다**: 의뢰 · 지원 · 미션 · 채팅 데이터의 조회 · 생성 · 수정 · 상태 전이, 연관 cascade(의뢰 취소 → 지원 REJECTED, 미션 생성 → 지원 ACCEPTED/REJECTED + 의뢰 MATCHED 등), 유효성 검사(`RepositoryError`), ID 발급.
- **`Test*RepositoryImpl` 은 어댑터**: 프로토콜 구현 + 지연 시뮬레이션(`Task.sleep`) + 요청 매핑(`DummySession` · 날짜 문자열 등) 후 `await store.xxx` 위임만 한다. 상태 변경 로직을 넣지 않는다.
- 새 더미 기능: 상태 · cascade 가 필요하면 store 에 메서드를 추가하고, `Test*RepositoryImpl` 에는 sleep + 매핑 + 호출만 추가한다.
- 더미에서도 대화방을 숨기는 조건을 두지 않는다 (`core` 의 채팅 정책).
