## 응답 DTO는 응답 스키마별 분리, 엔티티는 공유

### 1. 응답 DTO = 응답 스키마별 분리 (같은 스키마는 공유)

**서로 다른 엔드포인트의 응답 스키마가 다르면** 응답 DTO를 **각각 분리**한다. 스키마가 다른 여러 엔드포인트 응답을 하나의 DTO에 Optional 필드로 욱여넣어 재사용하지 말 것.

**Why:** 스키마가 다른 응답을 한 DTO로 묶어 optional 로 떡칠하면, 어떤 필드가 어느 엔드포인트에 오는지 추적이 안 되고 관리가 불가능해진다.

**단, 아래 두 경우는 분리하지 않고 하나의 DTO를 쓴다:**

- **같은 엔드포인트가 상태에 따라 필드를 다르게 줄 때** → 그 필드를 optional(`?`)로 둔 **하나의 DTO**로 받는다. 이건 "여러 응답 재사용"이 아니라 한 응답 스키마의 정상적인 optional 이다.
- **서로 다른 엔드포인트가 같은 스키마를 반환할 때** → 새 DTO를 만들지 말고 **하나를 공유**한다.

**How to apply:**

- `GET /v1/proposal/{id}` 가 상태(HOLDING/MATCHED/DISPUTED…)별로 `matchedAt`·`disputedAt` 유무가 달라짐 → 상태별 DTO를 만들지 말고 `ProposalDetailResponseDTO` **하나**에 그 필드들을 optional 로 둔다.
- `confirm-received`·`dispute` 액션 엔드포인트가 `GET /v1/proposal/{id}` 와 **동일한 `ProposalDetailResponse` 스키마**를 반환 → 별도 DTO 없이 `ProposalDetailResponseDTO` 를 재사용한다.
- 두 엔드포인트의 응답 **스키마 자체가 다르면** → DTO를 각각 만든다.

### 2. Domain 엔티티 = 최대한 공유

엔티티는 반대로 **최대한 공유**한다. 응답 DTO마다 무조건 새 엔티티를 만들지 않는다.

- 클라이언트가 실제 사용하는 필드가 같으면 여러 DTO의 `toDomain()` 이 **같은 엔티티**(예: `Proposal`)로 매핑한다.
- 응답별로 다른 필드를 **클라이언트가 실제로 화면/로직에서 사용할 때만** 새 엔티티(예: `ProposalDetail`)로 분리한다.
- 클라이언트가 안 쓰는 응답 전용 필드는 엔티티에 넣지 말고 `dto-entity-server-align` 규칙(`toDomain()` TODO 주석)으로 처리한다.
- 여러 응답에 공통으로 임베드되는 nested DTO(예: `ProposalOwnOfferResponseDTO`)도 하나로 공유한다.

**예시:** 스키마가 서로 다른 응답 DTO라도 클라이언트가 쓰는 필드가 같으면(`id/title/content/deadline/errandFee/status`) → `toDomain()` 은 모두 같은 `Proposal` 로 매핑한다.
