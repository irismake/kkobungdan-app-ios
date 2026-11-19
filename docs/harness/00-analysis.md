# 하네스 엔지니어링 1단계 — 현황 분석 및 도입 계획

> 작성일: 2026-11-19 · 대상: 꼬붕단 iOS (`kkobungdan/kkobungdan-app-ios`)
> 이 문서는 분석·설계안이다. 각 단계는 논의 후 구현한다.

## 결정 사항

| 항목 | 결정 |
|---|---|
| 지원 에이전트 | **Claude Code · Codex** 두 가지. Cursor 는 사용하지 않아 규칙 사본을 제거했다. |
| 에이전트 수 | **역할당 하나.** 교차 모델 리뷰(Codex 가 Claude 결과를 다시 리뷰 등)는 하지 않는다. 토큰 절약 우선. |
| 중복 검증 | AI 를 더 붙이지 않고 **결정적 스크립트**(lint · validator · CI)로 해결한다. |
| `no-build-verification` 규칙 | 4단계에서 개정: 스킬의 TDD 단계에서는 요청 없이 테스트 실행, 그 밖의 빌드는 요청 시만. |
| Required Status Check | dev·staging·main 모두 [CI.md](../CI.md) 표대로 등록되어 동작 중이다. 하네스 범위에서 제외. |
| 성과 측정 | 벤치마크 · 수동 지표 기록은 하지 않는다. 기준선 + 토큰 · 시간 · CI 자동 집계만 유지. |
| 진행 방식 | 하네스 작업은 브랜치 `chore/harness` 하나에서 단계마다 커밋 하나. push · PR 은 사용자 요청 시에만. 하네스 자체가 관리 부담이 되지 않게 최소 구조로, 필요한 것만 단계적으로 추가한다. |

---

## 1. 프로젝트 구조 및 아키텍처

| 항목 | 현황 |
|---|---|
| UI | SwiftUI · MVVM (`@Observable`, `ObservableObject` 미사용) |
| 계층 | `Presentation` / `Domain`(Entity · UseCase · Repository 프로토콜) / `Data`(DTO · Repository 구현), 기능 폴더 단위 |
| DI | `DIContainer` static enum, `isDummy` 플래그로 실 API ↔ `Test*RepositoryImpl` 전환 |
| 더미 | `DummyBackendStore` actor 에 상태 전이·cascade 집중 |
| 네트워크 | `HTTPClient`(async/await) · `TokenRefreshHandler` |
| 라우팅 | `AppRouter` / `AuthRouter` · 푸시 라우팅 |
| 동시성 | `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, Approachable Concurrency. **`SWIFT_VERSION = 5.0`** (Swift 6 엄격 검사 꺼짐). `DispatchQueue` 미사용 |
| 규모 | 앱 Swift 파일 약 320개 · iOS 18.6+ · Xcode 26.6 · SPM · fastlane(match) · Firebase |

## 2. 현재 에이전트 규칙 및 자동화

- 9개 도메인 규칙을 Claude(`.claude/rules`) · Codex(`.codex/rules`)에 동일 문구로 유지. 수동 동기화, 일치 여부 자동 검사 없음.
- 규칙은 항상 전부 로드된다 (작업 경로별 선택 로딩 없음).
- 훅 · 스킬 · 서브에이전트 없음.
- 프로젝트 지식 일부가 개인 auto-memory 에만 있어 다른 에이전트와 공유되지 않는다.
- 문서화되지 않은 규칙: 아키텍처·의존성, 동시성, Git·커밋·PR, 테스트, 에이전트 금지 행동.
- **규칙만 있고 강제가 없는 사례**: logging 규칙이 `print` 를 금지하지만 `TokenStorage.swift` 에 `print` 가 남아 access token 을 출력한다 (DEBUG 한정). → 5단계 첫 재발 방지 사례.

## 3. 테스트 및 CI/CD

- 테스트: `KkobungdanTests` 3개 파일 · 19개 테스트 — OpenAPI 계약 테스트, 알림 디코딩, HTTPClient 401 처리. ViewModel·UseCase·UI 테스트 없음.
- CI: PR 에서 Branch policy · Lint(Linux), Merge Queue 에서 Unit tests / Staging · Release 빌드 + 설정 검증(macOS). 자세한 내용은 [CI.md](../CI.md).
- CD: staging → TestFlight, main → App Store 심사 제출, hotfix → 역반영 PR 자동 생성. [CD.md](../CD.md).
- **PR 단계에는 빌드가 없다** → 컴파일 오류가 Merge Queue 에서 처음 발견된다.
- SwiftLint warning 은 머지를 막지 않는다.

## 4. 문제점 및 개선 영역

| # | 문제 | 영향 |
|---|---|---|
| P1 | 규칙이 문서로만 존재, 강제 장치 없음 | 위반해도 CI 통과 |
| P2 | 규칙 2벌 수동 동기화, drift 검사 없음 | 불일치 위험 |
| P3 | 규칙 전부 상시 로드 | 규칙이 늘수록 토큰 증가·지시 희석 |
| P4 | 로컬 빠른 검증 없음, 빌드는 Merge Queue 에서 처음 | 피드백 지연·macOS 러너 낭비 |
| P5 | Swift 5 모드 | 동시성 실수를 컴파일러가 못 잡음 |
| P6 | Presentation·Domain 테스트 없음 | 회귀 테스트 틀 없음 |
| P7 | `isDummy = true` 커밋 · Secrets 수정 · 보호 브랜치 push 방지 장치 없음 | 사고가 배포까지 이어질 수 있음 |
| P8 | 측정 없음 | 도입 효과 증명 불가 |
| P9 | 프로젝트 지식이 개인 메모리에 있음 | 에이전트 간 단절 |

가장 자주 반복된 작업(커밋 이력 기준): **서버 계약 업데이트 → DTO 반영 → 계약 테스트 등록**. 1순위 스킬 후보.

## 5. 도입 목표 및 범위

- **포함**: 규칙 단일 출처화, 결정적 검증 스크립트(에이전트 훅 · git 훅 · CI 에서 공유), 위험도별 실행 경로, 실수 → 강제 장치 피드백 루프, 측정.
- **제외**: 자체 오케스트레이터 런타임, 멀티 에이전트 프레임워크, 교차 모델 리뷰, CLI 로 충분한 작업용 MCP, PR 단계 macOS 빌드(측정 후 판단).

## 6. 권장 하네스 아키텍처

원칙: **검증 스크립트 하나를 세 곳에서 호출한다.** 에이전트가 훅을 우회해도 CI 에서 같은 스크립트가 막는다.

```
L4 Context   .harness/rules (원본) ◀── .claude/rules (심볼릭 링크) · AGENTS.md (선택 표)
L3 Workflow  skills + 위험도별 경로 (S/M/L)
L2 Trigger   Claude 훅 │ git 훅 (pre-commit · commit-msg) │ CI Lint job
L1 Gate      Scripts/harness/*.sh  (빠른 검증 / 전체 검증)
L0 Enforce   Required checks + Merge Queue  (이미 동작 중)
```

### 결정적 검증 vs AI 판단

| 스크립트 (결정적) | AI 판단 |
|---|---|
| 위험 명령 차단 (`push --force`, `reset --hard`, 보호 브랜치 push, `gh pr merge`, `fastlane`) | 요구사항 충족 여부 |
| 보호 파일 변경 차단 (`Secrets*.xcconfig`, `.github/workflows`, `fastlane/`) | 설계 적합성 |
| SwiftFormat · SwiftLint · 커스텀 규칙 (`no_print` 등) | 컴파일러가 못 잡는 동시성 경합 |
| `isDummy == false` | 도메인 용어·네이밍 |
| Domain 계층 SwiftUI·UIKit·Data import 금지 | 테스트 충분성 |
| 새 `*ResponseDTO` 계약 테스트 등록 여부 | |
| 규칙 사본 drift · 커밋 메시지 형식 · 빌드 · 유닛 테스트 | |

CI 연계: 새 검증은 기존 `Lint` job 의 step 으로 추가한다 → Required check 이름이 바뀌지 않아 브랜치 보호 재설정 불필요.

### 위험도별 실행 경로

| 경로 | 조건 | 흐름 |
|---|---|---|
| S | 문구·스타일, 단일 파일 | 구현 → 빠른 검증 |
| M | 단일 계층 기능·버그 | 짧은 계획 → 구현·테스트 → 전체 검증 |
| L | 다계층, Network·Token·DIContainer·pbxproj·CI 변경, 계약 변경 | 계획 → **사용자 승인** → 구현 → 리뷰어 서브에이전트 1개 → 수정 1회 → 전체 검증 |

- 서브에이전트는 L 경로의 리뷰어 하나만 둔다. Orchestrator 는 메인 세션이 맡는다.
- 변경 경로로 경로를 일부 자동 판정한다 (위험 경로 → 강제 L).

### 스킬 후보 (9개 → 6개)

`plan`(요구사항+설계) · `implement`(구현+단위 테스트+리팩토링 모드) · `bugfix`(재현 테스트 먼저 → incident 연결) · `review` · `pr` · `api-contract-sync`. 통합 테스트 스킬은 인프라가 생긴 뒤.

### 피드백 루프 강제 사다리

실수 발생 시 재발 방지 수단을 반드시 고른다: ① 테스트·lint·validator → ② 훅 → ③ 규칙 문구 → ④ 메모리 기록. ③·④만 고르면 자동화할 수 없는 사유를 남긴다.

## 7. 권장 디렉터리 구조

```
AGENTS.md / CLAUDE.md     # 진입점 (2단계 확정 구조: 02-rules.md)
.harness/
  rules/                  # 규칙 단일 출처 (적용 경로 frontmatter)
  skills/<name>/SKILL.md
  agents/reviewer.md
  memory/{decisions,incidents}/ · CHANGELOG.md
  metrics/                # 스키마·집계 스크립트만 커밋, 원본 이벤트는 gitignore
Scripts/harness/          # 검증 스크립트
.claude/settings.json     # 훅 등록
```

`Scripts/harness/` 는 `detect-app-changes.sh` 의 앱 코드 경로에 포함해 스크립트 변경 시에도 CI 가 돌게 한다.

## 8~9. 단계별 계획 · 산출물 · 완료 조건

> 2026-11-19 계획 수정: 하네스가 무거워지지 않도록 성과 측정(벤치마크 · 수동 지표)은 빼고 실제 개발 환경 개선에 집중한다. 측정은 기준선 문서와 토큰 · 시간 · CI 자동 집계만 유지한다.

| 단계 | 산출물 | 완료 조건 |
|---|---|---|
| 1. 현황 분석 | 이 문서 · Cursor 제거 · 기준선 ([01-baseline.md](01-baseline.md)) | 합의 ✅ |
| 2. 규칙 단일 출처화 · 컨텍스트 최적화 | `.harness/rules` (공통 원본), 작업별 선택 로딩, 규칙 정비, 일치 검사 스크립트 ([02-rules.md](02-rules.md)) | Claude · Codex 가 같은 원본을 참조, 공통 규칙만 상시 로드 ✅ |
| 3. 에이전트 역할 분리 | `.harness/agents/` (planner · reviewer), `core.md` 작업 경로(S · M · L), Codex 수행 방법 ([03-roles.md](03-roles.md)) | Claude 에 역할 등록 · Codex 지침 연결 ✅ |
| 4. 작업 워크플로 · TDD | 스킬 4개 (feature · bugfix · api-sync · pr), 단일 테스트 실행 · 테스트 파일 등록 도구, 검증 규칙 개정 ([04-workflow.md](04-workflow.md)) | Claude 에 스킬 등록 · Codex 표 연결 ✅ |
| 5. 자동 검증 · Quality Gate | 코드 · 규칙 검사기, Claude 훅 3종, git 훅, `verify.sh` ([05-quality-gate.md](05-quality-gate.md)) | 위험 동작 차단 · 위반 검출 확인 ✅ |
| 6. 독립 AI 리뷰 · 피드백 루프 | reviewer 실행 확인, `feedback` 스킬 · 로그 ([06-review-feedback.md](06-review-feedback.md)) | 실제 리뷰 1회 · 기록 5건 ✅ |
| 7. 기존 CI/CD 연동 | 검증 스크립트를 기존 `Lint` job 에 연결 | — |
| 8. 실제 사용 · 측정 · 최적화 | 기준선 대비 비교 | — |

## 10. 예상 문제 및 트레이드오프

- 훅 지연·오탐 → 빠른 검증은 수 초 이내, 오탐도 incident 로 기록.
- Codex 의 훅 지원 범위가 Claude 와 다를 수 있음 → git 훅 + CI 가 공통 차단선.
- 리뷰어 서브에이전트 토큰 → L 경로에만, 증가량 측정.
- 규칙 사본 대신 심볼릭 링크 하나 + 검사 스크립트로 불일치를 막는다 (생성 스크립트 없음).
- 1인 프로젝트라 표본이 작음 → 수치 + 사례 병행.
- "최초 통과율" 지표가 작업 쪼개기를 유도할 수 있음.

## 11. 효과 측정

| 지금 측정 가능 (과거 포함) | 계측 필요 | 대리 지표 |
|---|---|---|
| Merge Queue 최초 통과율, Lint 실패율, PR 당 커밋 수, 기능 PR 후 N일 내 `fix:` 비율, CI 소요 시간 | Claude 토큰·비용, 서브에이전트 실행 수, 훅 차단 건수, 리뷰 findings 수 | 요구사항 충족도(사용자 판정), 실수 재발률(incident 태그 누적 후), Codex 토큰(로그 형식 확인 필요) |

기준선: 최근 PR 약 50건의 CI 기록 + 도입 전 2주 작업 로그. 원본 이벤트는 gitignore, 시크릿·토큰 값은 기록하지 않는다.
