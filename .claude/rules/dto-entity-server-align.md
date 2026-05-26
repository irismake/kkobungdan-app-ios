## DTO·엔티티 서버 스키마 일치

API 응답 DTO와 Domain 엔티티는 서버 스펙을 기준으로 맞춘다. (`separate-dto-entity` 규칙과 함께 적용 — 응답마다 타입은 분리하되, 각 타입 내부 필드는 아래를 따른다.)

1. **DTO는 서버와 일치**: API 응답 DTO의 프로퍼티·`CodingKeys`·필수/옵셔널 여부는 서버 JSON 스펙과 **반드시** 같게 둔다. 서버에 있는 키를 DTO에서 빼거나, 서버에 없는 키를 DTO에 넣지 않는다.

2. **엔티티는 DTO와 일치**: Domain 엔티티는 해당 DTO와 **같은 필드 집합**을 갖는다. `toDomain()` 은 필드 단위 1:1 매핑이 원칙이다.

3. **서버 필수·클라이언트 미사용**: 서버 스펙상 필수이거나 응답에 포함되지만, 앱에서 아직 쓰지 않는 필드는 DTO·엔티티 **둘 다** 프로퍼티로 두고, 타입에 맞는 **빈 값**으로 채운다.
   - `String` → `""`
   - `Int` / `Int64` → `0`
   - `Bool` → `false`
   - `Date` → 스펙·화면에 맞는 기본값(동일 응답의 다른 날짜 필드 파싱값 등). 임의 sentinel 은 TODO 와 함께 이유를 적는다.
   - 서버가 optional 이면 `nil`, 서버가 required 이면 non-optional + 빈 값

4. **TODO 표시**: 위 빈 값·임시 필드·`toDomain()` 의 placeholder 매핑에는 `// TODO:` 로 **추후 제거·교체 예정**임을 남긴다. 서버 연동·UI 반영 후 필드·TODO 를 함께 정리한다.

**예시** (`toDomain()` — 서버에 아직 없거나 미사용인 필드):

```swift
// TODO: 서버 nickname 필드 연동 후 "" 제거
nickname: nickname.isEmpty ? "" : nickname,
```

```swift
// TODO: 서버에서 title 필드 추가·연동되면 "" · 0 · nil placeholder 제거
title: "",
errandFee: 0,
meetingAt: nil,
```
