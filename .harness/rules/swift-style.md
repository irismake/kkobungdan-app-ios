---
paths:
  - "**/*.swift"
---

# Swift 공통 컨벤션

## 포맷 · 린트

- 앱 소스(`Kkobungdan/`)는 SwiftFormat(`Kkobungdan/.swiftformat`, 들여쓰기 2칸) · SwiftLint(`Kkobungdan/.swiftlint.yml`)를 따른다. CI `Lint` 에서 SwiftFormat 위반 · SwiftLint error 는 머지를 막는다. 버전은 `.github/workflows/ci.yml` 에 고정.
- 테스트(`KkobungdanTests/`)는 SwiftFormat 대상이 아니다. 기존 파일처럼 들여쓰기 4칸.
- 주석 · 문서 주석(`///`)은 한국어. 코드만 봐서 알 수 없는 이유 · 제약을 적는다.

## 로깅

- `print` · `debugPrint` · `dump` 를 쓰지 않는다. `OSLog` 의 `Logger` 를 쓴다.
- 파일 단위 `private let xxxLogger = Logger(subsystem: "com.kkobungdan.Kkobungdan", category: "<기능>")`. category 는 기능 영역 (`Network` · `Auth` · `Push` …).
- **인증 정보(토큰 · 비밀번호 · Authorization 헤더 · 쿠키)를 로그에 넣지 않는다.** 필요하면 "저장 / 삭제", "있음 / 없음" 같은 상태만 남긴다 (`TokenStorage` 참고). 디버깅에 값이 꼭 필요하면 `privacy: .private` 로 가린다 (`AppDelegate` 의 FCM 토큰).
- 레벨: `debug`(개발 추적) · `info`(정상 흐름) · `warning` / `error` / `fault`(이상 · 실패). 예시는 `Data/Common/Network/HTTPClient.swift`.
