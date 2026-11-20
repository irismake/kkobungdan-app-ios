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
- 키 · 인증서(`*.p8` · `*.p12` · `*.mobileprovision` 등) · `.env` · `Secrets.*.xcconfig` 를 커밋하지 않는다 (`git add -f` 금지). 키를 코드 · 문서에 붙여 넣었으면 지우는 것으로 끝내지 말고 사용자에게 알려 폐기 · 재발급하게 한다.

## 작업 경로 · 역할

메인 세션이 **오케스트레이터 겸 구현자**다 (사용자와 대화 · 경로 판정 · 승인 받기 · 구현 · 테스트). 보조 역할은 `.harness/agents/` 의 **planner** · **reviewer** 둘뿐이고, 역할마다 에이전트 하나만 쓴다. 같은 일을 여러 에이전트 · 다른 모델로 중복 실행하지 않는다.

| 경로 | 기준 | 흐름 |
|---|---|---|
| S | 문구 · 스타일 · 한 파일의 단순 수정 | 바로 구현 |
| M | 한 계층 안의 기능 · 버그 | 계획을 몇 줄로 공유 → 구현 |
| L | 여러 계층에 걸침, 또는 위험 영역(`Data/Common/Network` · `Common/Token` · `DIContainer` · `project.pbxproj` · CI/CD · 서버 계약 · 동시성) | planner → **사용자 승인** → 구현 → reviewer → 지적 반영 → 재검토는 1회까지 |

- 애매하면 한 단계 위 경로를 고른다. 사용자가 요청하면 경로와 관계없이 planner · reviewer 를 쓴다.
- reviewer 에게는 요구사항과 비교 기준 ref 만 넘긴다. 구현 과정 설명을 넘기지 않는다 (독립성).
- reviewer 지적은 하나씩 "반영 / 반영 안 함(이유)" 으로 정리해 사용자에게 보고한다.
- 사용자가 실수를 지적했거나, 같은 유형의 문제가 다시 나왔거나, 규칙이 실제 코드와 다르면 `feedback` 스킬로 재발 방지 수단(검사 · 테스트 · 규칙)까지 반영한다. 기록은 `.harness/feedback-log.md`.

## Git

- 브랜치: `feat/` · `fix/` · `refactor/` · `chore/` · `ci/` · `style/` + kebab-case, `dev` 에서 분기. 긴급 수정만 `hotfix/*` (main 에서 분기).
- 커밋 메시지: `<type>: <한국어 요약>` (예: `fix: 스플래시 중 강제 로그아웃 신호를 놓치는 문제 수정`).
- 머지 방식 · 승격 · hotfix 절차는 `docs/Deployment/CI.md` 를 따른다.

## 작업 절차 · 빌드 · 테스트

- 반복 작업은 스킬(`.harness/skills/`)을 따른다: `feature`(기능 · 리팩토링, TDD) · `bugfix`(재현 테스트 먼저) · `api-sync`(서버 계약 반영) · `pr`(커밋 · PR, 요청 시만) · `feedback`(실수 → 재발 방지).
- 테스트는 `./Scripts/test.sh <테스트클래스>[/<메서드>]` 로 **해당 테스트만** 실행한다. 스킬의 TDD 단계(RED · GREEN)에서는 사용자 요청 없이 실행한다.
- 작업을 마치기 전에 `Scripts/harness/verify.sh` (규칙 일치 · 코드 규칙 · SwiftFormat · SwiftLint, 수 초) 를 통과시킨다. Claude 는 편집 · 종료 훅이 자동으로 검사하고, 위험 명령 · 보호 파일은 훅이 막는다.
- **로컬 검증에 빌드 · 전체 테스트를 넣지 않는다** (오래 걸린다). 전체 테스트 · Debug · Staging · Release 빌드는 CI Merge Queue 가 맡는다. 사용자가 요청할 때만 로컬에서 실행한다.
- 실행하지 않은 검증은 결과를 보고하지 않는다 ("빌드 성공" · "테스트 통과" 등). 실행 결과만 근거로 쓴다.

## 규칙 관리

- 규칙 원본은 `.harness/rules/` 하나뿐이다. `.claude/rules` 는 이 폴더의 심볼릭 링크다. 사본을 만들지 않는다.
- 꼬붕단 프로젝트 규칙 · 결정은 에이전트 개인 메모리가 아니라 여기에 적는다. (개인 메모리는 다른 에이전트가 못 읽는다)
- 규칙 파일을 추가 · 삭제 · 이름 변경하면 `AGENTS.md` 표도 고치고 `python3 Scripts/harness/check_rules.py` 로 확인한다.
- 코드나 `docs/` 에서 알 수 있는 내용은 규칙에 옮겨 적지 않고 위치만 가리킨다.
