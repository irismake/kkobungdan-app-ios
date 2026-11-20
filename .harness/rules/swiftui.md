---
paths:
  - "Kkobungdan/Presentation/**"
  - "Kkobungdan/Common/Components/**"
  - "Kkobungdan/Common/Extensions/View+*.swift"
  - "Kkobungdan/Common/Extensions/UIColor+AppColors.swift"
  - "Kkobungdan/Common/Consts/**"
---

# SwiftUI 화면 · 컴포넌트

## 기존 스타일 우선

- 공통 컴포넌트(`Common/Components/` — `AppBar` · `BottomActionBar` · `ContentTextField` · `Badge` 등) · 텍스트 스타일 · 색 토큰(`Color.gray900` 등, `UIColor+AppColors.swift`)을 먼저 쓴다. raw 색 · 폰트를 새로 만들지 않고, 디자인 하나에 맞추려고 공통 컴포넌트에 옵션(예: 글자 크기)을 추가하지 않는다.
- 디자인(Figma) 값이 기존 것과 조금 다르면 **가장 가까운 기존 것으로 구현하고, 차이를 목록으로 보고한 뒤 맞출지 묻는다.** 새 `TextStyle` 케이스 · 토큰 밖 색 · 컴포넌트 옵션은 사용자가 승인했을 때만 추가한다.

## 텍스트 스타일

- 텍스트는 `View+TextStyle.swift` 의 `.textStyle(.xxx)` 로 그린다. `.font(...)` 를 직접 쓰지 않는다.
- 기존 스타일과 `fontName` · `fontSize` · `lineHeight` 가 같고 kerning 만 다르면 새 케이스 대신 `.textStyle(.caption2).kerning(-0.2)` 처럼 체이닝한다.

## 프리뷰 위치

- `#Preview` 는 View 파일 맨 아래에 둔다. `#Preview` 뒤에 다른 타입 · extension 을 선언하지 않는다.
- ViewModel 의 `static func preview()` 는 타입 본문이 아니라 파일 맨 아래 `// MARK: - Preview` extension 에 두고, 위에 "SwiftUI `#Preview` 전용 — 운영 코드에서 호출하지 않는다" 문서 주석을 단다. 운영 코드에서 호출하지 않는다.
