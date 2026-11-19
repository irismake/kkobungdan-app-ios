# 피드백 로그

에이전트 실수 · 규칙 위반 · 규칙 오류와 재발 방지 수단. 절차는 `.harness/skills/feedback/SKILL.md`. 최신이 아래.
Secret · 토큰 값 · 개인정보를 적지 않는다.

| # | 날짜 | 유형 | 무엇이 잘못됐나 | 원인 | 재발 방지 수단 | 확인 |
|---|---|---|---|---|---|---|
| 1 | 2026-11-12 | chat-visibility | 의뢰 · 지원 상태에 따라 채팅방을 숨기는 조건을 클라이언트 · 더미에 넣음 (반복 지적) | 규칙 없음 (개인 메모리에만 있었음) | 3: `core.md` 채팅 정책 (항상 로드), `dummy-backend.md` | 규칙 문구 — 숨김 조건은 패턴이 다양해 자동 검사 불가 |
| 2 | 2026-11-13 | design-style | Figma 값에 맞춰 새 TextStyle · raw 색 · 컴포넌트 옵션을 임의로 추가 | 규칙 충돌 (`text-style` "없으면 추가" vs 사용자 결정 "먼저 묻기") | 3: `swiftui.md` 를 사용자 결정에 맞춤 / 1: Presentation `.font(` 검출 (`check_code.py`) | `.font` 는 임시 파일로 검출 확인 |
| 3 | 2026-11-19 | logging | `TokenStorage` 가 `print` 로 access token 출력 | 규칙은 있었지만 강제 없음 | 1: `check_code.py` logging + Claude 편집 · 종료 훅 + git pre-commit / 코드 수정 (`99944d5`) | 임시 파일로 검출 확인, 레포에 `print` 0건 |
| 4 | 2026-11-19 | test-registration | 새 테스트 파일이 테스트 타깃에 등록되지 않아 실행되지 않은 채 "통과" 로 보임 (하네스 작업 중 발견) | 테스트 타깃이 폴더 동기화가 아님 — 규칙 없음 | 1: `check_code.py` test-registration + 등록 도구 `add_test_file.py` / 3: `testing.md` | 임시 파일로 검출 · 등록 확인 |
| 5 | 2026-11-19 | rule-mismatch | `architecture.md` 가 "ViewModel 에서 DIContainer 사용 금지" 라고 했지만 실제로는 상위 View · 프리뷰에서 조립 | 규칙이 틀림 (코드 확인 없이 작성) | 3: 규칙을 실제 코드에 맞춤, 해당 항목은 자동 검사에서 제외 | `check_code.py` 가 기존 코드에서 오탐 0건 |
