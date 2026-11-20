# 꼬붕단 iOS 하네스

Claude Code · Codex 가 **같은 규칙과 절차**로 일하게 하고, AI 판단에만 기대지 않도록 **결정적 검사로 품질을 강제**하는 개발 환경.
2026-11-19 도입 ([PR #59](https://github.com/kkobungdan/kkobungdan-app-ios/pull/59)). 단계별 설계 · 결과는 아래 문서.

| 문서 | 내용 |
|---|---|
| [00-analysis.md](00-analysis.md) | 현황 분석 · 결정 사항 · 단계 계획 |
| [01-baseline.md](01-baseline.md) | 도입 전 기준선 (PR · CI · 토큰 · 규칙 로딩) |
| [02-rules.md](02-rules.md) | 규칙 단일 출처 · 선택 로딩 |
| [03-roles.md](03-roles.md) | 역할 (planner · reviewer) · 작업 경로 |
| [04-workflow.md](04-workflow.md) | 스킬 · TDD |
| [05-quality-gate.md](05-quality-gate.md) | 자동 검증 · 훅 · 필수 검사 항목 |
| [06-review-feedback.md](06-review-feedback.md) | 독립 리뷰 · 피드백 루프 |
| [08-measure.md](08-measure.md) | 측정 · 최적화 기준 |
| [../Deployment/CI.md](../Deployment/CI.md) | PR · Merge Queue CI (7단계 연동 포함) |

---

## 1. 사용법

```sh
Scripts/harness/install-git-hooks.sh                  # 클론마다 한 번 (커밋 전 검사 · 메시지 형식)
Scripts/harness/verify.sh                             # 작업을 끝내기 전 (수 초) — hotfix 는 --base origin/main
./Scripts/test.sh <테스트클래스>[/<메서드>]            # TDD 중 테스트 하나만
python3 Scripts/harness/add_test_file.py <경로>        # 새 테스트 파일을 테스트 타깃에 등록
python3 Scripts/harness/check_rules.py                # 규칙 · 역할 · 스킬을 고친 뒤
python3 .harness/metrics/collect_agents.py --since <시각>   # 토큰 · 작업 시간 · 하네스 검사 기록
python3 .harness/metrics/collect_github.py --since <시각>   # PR · CI
```

- Claude Code: `.claude/settings.json` 의 훅과 `.claude/{rules,agents,skills}` 링크가 자동으로 적용된다.
- Codex: `AGENTS.md` 만 자동으로 읽는다. 거기서 `core.md` → 작업별 규칙 · 스킬 · 역할을 고르고, 끝내기 전에 `verify.sh` 를 실행한다.
- 규칙 · 결정을 바꿀 때는 `.harness/rules/` 만 고친다. 개인 에이전트 메모리에 적지 않는다.

## 2. 구조

```
CLAUDE.md                      Claude 진입점
AGENTS.md                      Codex 진입점 — 작업별 규칙 · 스킬 · 역할 선택 표, 검증 지시
.claude/
  rules  → ../.harness/rules   심볼릭 링크 (Claude 자동 로드)
  agents → ../.harness/agents  심볼릭 링크 (서브에이전트 등록)
  skills → ../.harness/skills  심볼릭 링크 (스킬 등록)
  settings.json                Claude 훅 3개
.harness/
  rules/        공통 규칙 원본 10개 — core 만 항상, 나머지는 paths 로 선택 로드
  agents/       planner · reviewer
  skills/       feature · bugfix · api-sync · pr · feedback
  feedback-log.md               실수 → 재발 방지 기록
  metrics/      collect_github.py · collect_agents.py (out/ 은 gitignore)
.githooks/      pre-commit · commit-msg
Scripts/harness/
  check_rules.py · check_code.py · verify.sh · add_test_file.py · install-git-hooks.sh · events.py
  hooks/        pre_tool.py · post_edit.py · stop.py
.github/workflows/ci.yml        Lint job 에 하네스 검사 2단계
```

## 3. 구성 요소

### 3-1. 규칙 (`.harness/rules/`)

| 규칙 | 로드 시점 | 내용 |
|---|---|---|
| core | 항상 | 도메인 용어 · 채팅 숨김 금지 · 작업 범위 · 승인 필요 작업 · Git · 작업 경로 · 검증 · 규칙 관리 |
| swift-style | `*.swift` | 포맷 · 린트 · Logger · 로그에 인증 정보 금지 |
| architecture | Domain · Data · ViewModel · Routing | 계층 · 의존 방향 · DI 조립 위치 · ViewModel 오류 처리 |
| swiftui | Presentation · Components | 기존 스타일 우선(다르면 먼저 묻기) · textStyle · 프리뷰 위치 |
| api | Data · 계약 테스트 | HTTPClient · DTO 서버 일치 · 엔티티 매핑 · 요청 바디 · 계약 등록 |
| reason-survey | 신고 · 탈퇴 · 분쟁 화면 · 데이터 | `requiresDetail` 서버 검증 |
| dummy-backend | Dummy · Test 저장소 · DIContainer | DummyBackendStore 역할 |
| concurrency | Data · ViewModel · Token · AppDelegate | 기본 MainActor 격리 · actor · 재진입 · 취소 |
| testing | 테스트 | pbxproj 등록 · 이름 · TDD |
| cicd | .github · fastlane · pbxproj 등 | 머지 방식 · hotfix · 배포 승인 · 같은 Bundle ID |

규칙은 코드 · `docs/Deployment/CI.md` · `docs/Deployment/CD.md` · 사용자 결정만 근거로 한다. 규칙과 코드가 다르면 규칙을 코드에 맞춘다.

### 3-2. 역할과 작업 경로

| 역할 | 담당 | 하는 일 |
|---|---|---|
| 오케스트레이터 · 구현자 | 메인 세션 | 대화 · 경로 판정 · 승인 · 구현 |
| planner | 서브에이전트 (읽기 전용) | L 작업 계획: 요구사항 · 영향 범위 · 적용 규칙 · 순서 · 위험 · 질문 |
| reviewer | 서브에이전트 (읽기 전용) | 요구사항 + 기준 ref 만 받아 diff 를 직접 리뷰. 근거 없는 지적 금지 |

| 경로 | 기준 | 흐름 |
|---|---|---|
| S | 단순 수정 | 바로 구현 |
| M | 한 계층 안 | 계획 공유 → 구현 |
| L | 여러 계층 · 위험 영역(Network · Token · DIContainer · pbxproj · CI/CD · 계약 · 동시성) | planner → 승인 → 구현 → reviewer → 재검토 1회 |

역할당 에이전트 하나. 교차 모델 리뷰 · 같은 일의 중복 실행은 하지 않는다. Codex 는 같은 세션에서 planner 형식으로 계획하고, 독립 리뷰는 새 세션에서 한다.

### 3-3. 스킬 (`.harness/skills/`)

| 스킬 | 언제 | 핵심 |
|---|---|---|
| feature | 기능 추가 · 변경 · 리팩토링 | 경로 판정 → 기존 구조 → RED → GREEN → REFACTOR → verify → (L) reviewer |
| bugfix | 버그 | 원인(코드 근거) → 재현 테스트 RED → 수정 → 재발 방지 제안 |
| api-sync | 서버 스펙 변경 | 스키마별 변경 표 → DTO · 엔티티 · 계약 테스트. 서버 접속 · lock 갱신은 사용자 확인 후 |
| pr | 사용자 요청 시만 | 기존 PR 본문 형식. 머지 · 큐 추가 안 함 |
| feedback | 실수 · 반복 지적 · 규칙-코드 불일치 | 재발 방지 수단(검사 > 테스트 > 규칙)까지 반영 · 확인 · 기록 |

### 3-4. 자동 검증

| 시점 | 장치 | 대상 | 결과 |
|---|---|---|---|
| 명령 실행 전 | Claude 훅 `pre_tool.py` | 위험 명령(`reset --hard` · 강제 push · 보호 브랜치 push · `gh pr merge` · `fastlane` …) · 보호 파일(`Secrets*.xcconfig` · 인증서 …) | deny. push · PR · CI/CD · 하네스 변경은 확인 창 |
| 편집 직후 | Claude 훅 `post_edit.py` | 고친 Swift 파일 하나 | Claude 에게 돌려줘 바로 수정 |
| 응답 종료 전 | Claude 훅 `stop.py` | 브랜치 변경 전체 | 한 번 막고 이유 전달 |
| 작업 완료 | `verify.sh` | 브랜치 변경 전체 | Codex · 사람용 |
| 커밋 | git `pre-commit` · `commit-msg` | stage 된 변경 · 메시지 형식 | 커밋 거부 |
| PR | CI `Lint` (Harness rules · Harness code rules) | PR 변경 전체 | Required check — 실패하면 큐에 못 넣음. 위반은 PR 줄 주석 |
| 머지 직전 | Merge Queue (기존) | 대상 브랜치 + PR | Debug · Staging · Release 빌드 · 유닛 테스트 · 서버 설정 검증 |

`check_code.py` 검사 (추가된 줄 · 새 파일만):

| 검사 | 내용 |
|---|---|
| secret-file | `*.p8` · `*.p12` · `*.mobileprovision` 등 · `.env*` · `Secrets.*.xcconfig` 커밋 (`git add -f` 포함) |
| secret-value | 개인 키 블록 · GitHub · AWS · Slack · Google · AI API 키 형식 (`GoogleService-Info.plist` 제외) |
| sensitive-log | 로그 보간 속 token · password · authorization 등 (`privacy: .private` 는 허용) |
| logging · text-style | `print` · `.font(` |
| contract-test | 계약 테스트에 등록 안 된 새 응답 DTO |
| layer | Domain → UI · Data 계층, Presentation → DTO · HTTPClient |
| preview-placement | `#Preview` 뒤 선언 |
| test-registration | 테스트 타깃에 등록 안 된 새 테스트 파일 |
| `--lint` | SwiftFormat 0.60.1 · SwiftLint 0.65.1 (CI 와 같은 설정) |

판단이 필요한 것(요구사항 충족 · 설계 · 데이터 경합 · 테스트 충분성)은 reviewer 와 사람이 본다. 빌드 · 전체 테스트는 로컬 검증에 넣지 않고 Merge Queue 가 맡는다.

### 3-5. 피드백 루프

```
실수 발견 → 로그에서 같은 유형 확인 → 원인 분류(규칙 없음 / 강제 없음 / 규칙이 틀림 / 로드 안 됨 / 검사 구멍)
→ 수단: ① 검사 · 훅 > ② 회귀 테스트 > ③ 규칙 문구 > ④ 기록만(사유 필수)
→ 반영 → 같은 실수를 만들어 실제로 걸리는지 확인 → .harness/feedback-log.md 기록
```

### 3-6. 측정

- 수집: `collect_github.py`(PR · CI), `collect_agents.py`(Claude · Codex 토큰 · 작업 시간 + 하네스 검사 기록)
- 하네스 검사 기록(`Scripts/harness/events.py`): 실행 위치 · 결과 · 규칙 ID · 경로만 로컬에 남긴다. 명령 내용 · 코드 · Secret 은 남기지 않는다. 수동 실행 · CI 는 기록하지 않는다.

## 4. 결과

| 지표 | 도입 전 | 도입 후 |
|---|---|---|
| 하네스가 세션마다 항상 쓰는 토큰 | 8,180 (규칙 9개 전부) | **2,135 (−74%)** |
| Claude 첫 호출 컨텍스트 | 38,170 | 31,958 (−16%) |
| 개인 메모리 로드 | 약 8,000 | 0 (레포 규칙으로 이관) |
| 규칙 사본 | 3벌 (Claude · Cursor · Codex) | 1벌 (+ 링크) |
| PR CI `Lint` | SwiftFormat · SwiftLint | + 하네스 검사 2단계 (24초) |

실사용 효과(로컬 vs CI 에서 잡힌 위반 · 작업당 토큰 · Merge Queue 최초 통과율 · 재발)는 dev 반영 후 2주 또는 작업 PR 10건이 쌓이면 [08-measure.md](08-measure.md) 대로 비교한다.

### 검증한 것

| 대상 | 방법 | 결과 |
|---|---|---|
| 규칙 선택 로딩 | 헤드리스 Claude 세션 기록 | 경로에 맞는 규칙만 로드 |
| 역할 · 스킬 등록 | 헤드리스 세션 init | planner · reviewer · 스킬 5개 |
| 실행 전 훅 | 25가지 판정 표 + 실제 세션 | `fastlane` · Secrets 쓰기 차단 |
| 코드 검사 | 위반을 넣은 임시 파일 · 새 클론 | 일반 7종 · 보안 5건 검출, 기존 코드 오탐 0 |
| 테스트 등록 도구 | 임시 파일 | 그룹 배치 · 반복 안전 · `plutil` · `xcodebuild -list` 통과 |
| reviewer | 앱 코드 수정 리뷰 | 통과, 낮음 2건 (약 2.4만 토큰 · 27초) |
| CI | 실제 GitHub Actions (PR #59) | Branch policy · Lint(하네스 단계 포함) 통과 |

## 5. 결정 사항

| 결정 | 이유 |
|---|---|
| Cursor 제거 | 사용하지 않음 |
| 역할당 에이전트 하나, 교차 리뷰 없음 | 토큰 절약. 중복 검증은 스크립트로 |
| 벤치마크 · 비교 실험 · 수동 지표 없음 | 하네스가 관리 부담이 되지 않게 |
| 로컬 검증에 빌드 · 전체 테스트 제외 | 오래 걸림. Merge Queue 가 맡음 |
| MCP 미도입 | 기존 CLI(`xcodebuild` · `simctl` · `gh`)로 충분 |
| Required check 변경 없음 | 이미 등록 · 동작 중. 기존 `Lint` 안에 단계 추가 |
| 비용(달러) 미계산 | 요금제마다 단가가 다름 — 토큰으로 비교 |

## 6. 한계

- Claude 훅은 Claude 에만 있다. Codex · 사람은 git 훅 · CI 가 차단선이고, git 훅은 클론마다 설치해야 한다.
- PR push 단계에는 빌드가 없어 컴파일 오류 · 테스트 실패는 Merge Queue 에서 처음 드러난다 (실패하면 브랜치에 반영되지 않는다).
- 키 값 검사는 형식이 확실한 키만 잡는다.
- 실행 전 훅은 명령 문자열 패턴으로 판단해, 문자열 안에만 있는 위험 명령도 막는다 (안전 쪽 오탐, `feedback-log.md` #6).
- Codex 경로는 실행 확인을 못 했다 (CLI 없음). PR 단계에서 위반이 실제로 막히는 경우는 로컬 재현으로만 확인했다.
- Claude 세션 로그는 기본 30일 뒤 삭제된다 (`cleanupPeriodDays`) — 측정 전에 집계하거나 설정을 늘린다.
