---
paths:
  - "Kkobungdan/Data/**"
  - "KkobungdanTests/OpenAPIContractTests.swift"
  - "KkobungdanTests/Contract/**"
  - "Scripts/sync-openapi.py"
---

# API 연동 · DTO · 오류

서버 스펙 원본: `KkobungdanTests/Contract/openapi.json` (`Scripts/sync-openapi.py` 로 갱신 — 손으로 고치지 않는다).

## 호출

- `HTTPClient` 의 `get` · `getOptional`(200 에 `data` 가 없으면 `nil`) · `post` · `put` · `postVoid` · `patchVoid` · `delete` 를 쓴다. 응답 봉투(`success` · `data` · `message`)와 snake/camel 변환은 `HTTPClient` 가 처리한다.
- 오류는 `RepositoryError`(`.server(code:message:)` 등)로 올라온다. 서버 오류 코드는 `ServerErrorCode`.

## 응답 DTO

- **서버 스펙과 완전히 일치**: 프로퍼티 이름 · `CodingKeys` · optional 여부를 서버 스키마와 같게 한다. 서버 required → non-optional, optional → `?`. 서버에 없는 키를 넣거나 있는 키를 빼지 않는다.
- **스키마별로 분리, 같은 스키마는 공유**: 엔드포인트마다 스키마가 다르면 DTO 를 따로 만든다 (여러 응답을 optional 로 한 DTO 에 몰지 않는다). 같은 엔드포인트가 상태에 따라 필드를 다르게 주면 하나의 DTO 에 optional 로 둔다. 다른 엔드포인트가 같은 스키마를 주면 DTO 를 공유한다 (예: `confirm-received` · `dispute` → `ProposalDetailResponseDTO`). 여러 응답에 들어가는 nested DTO 도 공유.
- **계약 테스트 등록 필수**: 새 응답 DTO 는 `OpenAPIContractTests.contracts` 에 `DecodeContract("<서버 스키마명>", decoding(XxxDTO.self))` 로 등록한다. 스키마명은 `Fixtures/generated/<스키마명>.json` 과 같다. 같은 스키마를 공유하는 DTO 는 각각 한 줄씩. 호출 엔드포인트가 스펙에 없으면 등록하지 않고 배열에 사유 주석을 남긴다.

## 엔티티 매핑

- 엔티티는 **클라이언트가 실제로 쓰는 필드만** 둔다. 안 쓰는 필드는 optional 로도 남기지 않는다.
- 엔티티는 최대한 공유한다. 쓰는 필드가 같으면 여러 DTO 의 `toDomain()` 이 같은 엔티티로 매핑한다 (예: `Proposal`). 화면에서 다른 필드를 실제로 쓸 때만 새 엔티티(예: `ProposalDetail`).
- DTO 에만 있는 필드는 stub 상수를 만들지 않고 `toDomain()` 맨 위에 한 줄 TODO 로 남긴다: `// TODO: itemPrice, totalAmount … UI 반영 시 엔티티에 추가`

## 요청 바디

- 응답 DTO 와 같은 원칙으로 서버 요청 스키마와 완전히 일치시킨다. 새 요청 바디는 `requestContracts` 에 `EncodeContract` 로 등록한다.
- 서버가 받지만 UI 가 아직 없는 필드는 struct 에 선언하고 `static let stubXxx` 기본값 + TODO 로 보낸다. UI 반영 시 호출부 실제 값으로 바꾸고 stub 을 지운다.

## 사유 입력

- 분쟁 · 신고 · 탈퇴의 `detailReason` 정책은 `reason-survey.md` 를 따른다 (스펙에 드러나지 않는 서버 검증이 있다).
