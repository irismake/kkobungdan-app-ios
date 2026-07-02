## 응답 DTO는 계약 테스트에 등록

새 **응답 DTO** 를 추가하면 **반드시** `KkobungdanTests/OpenAPIContractTests.swift` 의 `contracts` 배열에도 한 줄 등록한다. 그래야 그 DTO 가 서버 OpenAPI 스펙과 맞는지 자동 검증된다.

**Why:** 등록을 빠뜨리면 그 DTO 는 서버 변경을 자동 감지하지 못해, "API 바뀌면 빨간불" 안전망에 구멍이 생긴다.

**등록 방법:** DTO 가 매핑되는 **서버 스키마명**(OpenAPI `components/schemas` 의 이름)을 첫 인자로 준다.

```swift
DecodeContract("UserDetailResponse", decoding(UserDetailResponseDTO.self)),
```

- 스키마명은 `Scripts/sync-openapi.py` 가 생성하는 `KkobungdanTests/Fixtures/generated/<스키마명>.json` 파일명과 같아야 한다.
- 여러 DTO 가 같은 서버 스키마를 공유하면(예: `OfferResponseDTO`·`OfferDetailResponseDTO`·`MyOfferResponseDTO` → `OfferResponse`) 각각 한 줄씩 등록한다.

**예외:** 호출 엔드포인트가 **현재 서버 OpenAPI 스펙에 없는** DTO(예: Oauth `LoginResponseDTO`·`AppleLoginResponseDTO`·`KakaoLoginResponseDTO`)는 대조할 스키마가 없으므로 등록하지 않는다. 대신 `contracts` 배열에 **주석으로 사유를 남긴다.** (나중에 서버 스펙에 추가되면 그때 등록)
