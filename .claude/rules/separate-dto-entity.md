## API 응답마다 별도 DTO/엔티티

API 응답 형태가 다르면 DTO와 Domain 엔티티를 별도로 만들어야 한다. 기존 타입에 Optional 필드를 추가해서 재사용하지 말 것.

**Why:** 목록/상세/생성 응답이 필드 구성이 다른데 같은 DTO+엔티티를 쓰면 스파게티 코드가 된다.

**How to apply:** 예를 들어 `POST /v1/proposal` 응답에 새 필드(meetingAt, itemPrice, deposit)가 생기면 `ProposalResponseDTO/Proposal`을 수정하지 말고 `ProposalDetailResponseDTO/ProposalDetail` 같은 별도 타입을 추가한다.
