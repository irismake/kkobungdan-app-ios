## DTO·엔티티 서버 스키마 일치

API 응답 DTO와 Domain 엔티티는 서버 스펙을 기준으로 맞춘다. (`separate-dto-entity` 규칙과 함께 적용 — 응답마다 타입은 분리하되, 각 타입 내부 필드는 아래를 따른다.)

---

## 응답 DTO (Decodable)

### 1. 응답 DTO = 서버 스펙 완전 일치

- 프로퍼티 이름·`CodingKeys`·**optional/required 여부**를 서버 JSON 스펙과 **반드시** 동일하게 유지한다.
- 서버에 있는 키를 빼거나, 서버에 없는 키를 넣지 않는다.
- 서버가 required → Swift non-optional, 서버가 optional → Swift `?`.

### 2. 엔티티 = 클라이언트가 실제 사용하는 필드만

- 앱에서 실제로 참조하는 필드만 엔티티에 둔다.
- 클라이언트 미사용 필드는 엔티티에 추가하지 않는다. **optional 로 남기지도 않는다 — 아예 제거.**

### 3. 미사용 필드 처리 (응답 DTO 있음 / 엔티티 없음)

DTO에는 있지만 엔티티에 없는 필드는 **별도 stub 상수를 만들지 않는다.** 매핑하지 않는 필드 목록을 `toDomain()` 상단에 한 줄 TODO 주석으로만 남긴다.

```swift
func toDomain() -> Mission {
  // TODO: itemPrice, totalAmount … UI 반영 시 엔티티에 추가
  Mission(id: id, ...)
}
```

---

## 요청 바디 (Encodable)

### 4. 요청 바디 = 서버 스펙 완전 일치

응답 DTO와 동일한 원칙을 적용한다.

- 프로퍼티 이름·`CodingKeys`·**optional/required 여부**를 서버 요청 스펙과 **반드시** 동일하게 유지한다.
- 서버가 받는 키를 빼거나, 서버가 받지 않는 키를 넣지 않는다.

### 5. 클라이언트 미구현 필드 처리 (서버는 받지만 UI 미구현)

서버가 받는 필드지만 클라이언트가 아직 UI를 구현하지 않은 경우:

1. **요청 바디 struct에 필드 선언**: 서버 스펙대로 필드를 두고, stub 상수를 기본값으로 사용한다.

   ```swift
   struct SomeRequestBody: Encodable {
     let action: String
     // TODO: imageUrl UI 연동 전까지 stub 값 전송
     let imageUrl: String? = SomeRequestBody.stubImageUrl
   }
   ```

2. **struct extension에 전역 stub 값 선언**: 테스트·더미 코드에서도 접근 가능하도록 `static` 상수로 추가한다.

   ```swift
   extension SomeRequestBody {
     // TODO: imageUrl UI 반영 시 호출부에서 실제 값 전달로 교체
     static let stubImageUrl: String? = nil
   }
   ```

---

## TODO 정리 시점

UI 반영·서버 연동이 완료되면:
- **응답**: 해당 필드를 엔티티에 추가하고 `toDomain()` TODO 주석을 제거한다.
- **요청**: 호출부에서 실제 값 전달로 교체하고 `stubXxx` 상수와 TODO를 함께 제거한다.

---

## 예시

```swift
// ── 응답 DTO ──────────────────────────────
struct MissionResponseDTO: Decodable {
  let runFee: Int
  let itemPrice: Int         // required → non-optional
  let disputeReason: String? // optional → ?
}
func toDomain() -> Mission {
  // TODO: itemPrice, disputeReason — UI 반영 시 엔티티에 추가 (stub 상수 만들지 않음)
  Mission(runFee: runFee, ...)
}
struct Mission { let runFee: Int } // 사용 필드만

// ── 요청 바디 ──────────────────────────────
struct MissionActionBody: Encodable {
  let action: String
  // TODO: proofImageUrl — COMPLETE_DELIVERY UI 연동 전까지 stub 값 전송
  let proofImageUrl: String? = MissionActionBody.stubProofImageUrl
}
extension MissionActionBody {
  // TODO: proofImageUrl UI 반영 시 호출부에서 실제 값 전달로 교체
  static let stubProofImageUrl: String? = nil
}
```
