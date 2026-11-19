# 공통 규칙 (항상 적용)

꼬붕단 iOS — 심부름 중개 앱. SwiftUI · iOS 18.6+ · Swift 5 언어 모드(기본 격리 `MainActor`) · SPM · fastlane.
소스는 `Kkobungdan/{Presentation,Domain,Data,Common}`, 테스트는 `KkobungdanTests/`. 작업 대상에 맞는 규칙은 따로 읽는다 (Claude: 자동 / Codex: `AGENTS.md` 표).

## 도메인 용어

| 코드 | 뜻 |
|---|---|
| `Proposal` | 의뢰(요청) — 오더러가 올리는 심부름 글. 상태 `ProposalStatus` |
| `Offer` | 지원 — 꼬붕(러너, 코드 `runner`)이 의뢰에 지원. 상태 `OfferStatus` |
| 오더러 / 꼬붕 | 의뢰한 사람 / 수행하는 사람 |
| 미션 | 매칭 후 수행 단계 (`MissionAbort` = 중단) |
| `errandFee` | 수행비 |
| `Dispute` · `Settlement` · `Report` · `Withdraw` · `Activity` | 분쟁 · 정산(수행비 입금 계좌) · 신고 · 회원 탈퇴 · 내 활동 |

- **채팅(대화방)은 절대 숨기지 않는다.** 대화방은 꼬붕이 지원할 때 서버가 만들고 지우지 않는다 (지원 취소 · 미선택 · 의뢰 취소 · 분쟁 · 환불 후에도 남는다). 채팅 목록과 내 요청 · 내 지원 상세의 관련 대화는 서버가 준 목록 · 순서 · 상태를 그대로 보여 준다. 의뢰 · 지원 상태로 대화를 거르거나 대화 상태를 계산하지 않는다 (클라이언트 · 더미 모두).

## 작업 범위

- 요청받은 범위만 고친다. 관련 없는 리팩토링 · 포맷 변경 · 파일 이동을 섞지 않는다.
- 기존 아키텍처 · 컴포넌트 · 스타일을 따른다. 프로젝트에 없는 라이브러리 · 패턴을 들일 때는 먼저 묻는다.
- **사용자 승인 없이 하지 않는다**: 커밋 · push · PR 생성 · 머지(Merge Queue 포함) · 배포(TestFlight · App Store · `fastlane` 실행) · 브랜치 보호 · Secrets · GitHub 설정 변경.
- 실제 키가 든 파일(`Secrets*.xcconfig`, `GoogleService-Info.plist`)은 고치지 않는다. Secret · 토큰 값을 로그 · 문서 · 커밋 · 메모리에 남기지 않는다.

## Git

- 브랜치: `feat/` · `fix/` · `refactor/` · `chore/` · `ci/` · `style/` + kebab-case, `dev` 에서 분기. 긴급 수정만 `hotfix/*` (main 에서 분기).
- 커밋 메시지: `<type>: <한국어 요약>` (예: `fix: 스플래시 중 강제 로그아웃 신호를 놓치는 문제 수정`).
- 머지 방식 · 승격 · hotfix 절차는 `docs/CI.md` 를 따른다.

## 빌드 · 테스트 검증

- 작업을 마칠 때마다 `xcodebuild build` · `xcodebuild test` 를 스스로 돌리지 않는다. 사용자가 요청했을 때만 실행한다.
- 빌드로 검증하지 않았으면 "빌드 성공" 같은 결과를 보고하지 않는다.

## 규칙 관리

- 규칙 원본은 `.harness/rules/` 하나뿐이다. `.claude/rules` 는 이 폴더의 심볼릭 링크다. 사본을 만들지 않는다.
- 꼬붕단 프로젝트 규칙 · 결정은 에이전트 개인 메모리가 아니라 여기에 적는다. (개인 메모리는 다른 에이전트가 못 읽는다)
- 규칙 파일을 추가 · 삭제 · 이름 변경하면 `AGENTS.md` 표도 고치고 `python3 Scripts/harness/check_rules.py` 로 확인한다.
- 코드나 `docs/` 에서 알 수 있는 내용은 규칙에 옮겨 적지 않고 위치만 가리킨다.
