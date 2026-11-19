# 하네스 2단계 — 규칙 단일 출처화 · 컨텍스트 최적화

## 구조

```
.harness/rules/          ← 규칙 원본 (Claude · Codex 공용, 여기만 고친다)
  core.md                  항상 로드 — 도메인 용어 · 작업 범위 · 승인 필요 작업 · Git · 빌드 검증 · 규칙 관리
  swift-style.md           *.swift — 포맷 · 린트 · 로깅
  architecture.md          Domain · Data · ViewModel · Routing — 계층 · 의존 방향 · DI · ViewModel 오류 처리
  swiftui.md               Presentation · Components — 기존 스타일 우선 · 텍스트 스타일 · 프리뷰 위치
  api.md                   Data · 계약 테스트 — HTTPClient · DTO · 엔티티 매핑 · 요청 바디 · requiresDetail
  dummy-backend.md         Dummy · Test*RepositoryImpl · DIContainer
  concurrency.md           Data · ViewModel · Token · AppDelegate — 격리 설정 · actor · 재진입 · 취소
  testing.md               KkobungdanTests — XCTest 구성 · pbxproj 등록 · TDD
  cicd.md                  .github · Scripts/ci · fastlane · pbxproj — 브랜치 · 머지 · 배포 승인 · Bundle ID
.claude/rules → ../.harness/rules   심볼릭 링크 (Claude Code 자동 로드)
CLAUDE.md                Claude 진입점 — 원본 위치와 로딩 방식, Claude 전용 규칙 자리
AGENTS.md                Codex 진입점 — core 먼저, 작업 유형별 규칙 선택 표, Codex 전용 규칙 자리
Scripts/harness/check_rules.py   일치 검사
```

- **Claude Code**: `.claude/rules` 를 읽는다. frontmatter `paths` 가 없는 `core.md` 는 항상, 나머지는 `paths` 에 맞는 파일을 읽을 때 로드된다.
- **Codex**: `AGENTS.md` 만 자동으로 읽는다. 거기서 `core.md` 를 먼저 읽고 표에서 필요한 규칙만 고르게 한다. (`.codex/rules/` 는 Codex 가 인식하는 위치가 아니었다 — 사본이었을 뿐이라 삭제)

## 이전 규칙과의 대응

| 이전 (Claude · Codex · Cursor 각 사본) | 지금 |
|---|---|
| `00-ai-rules-unified` (사본 동기화 규칙) | 사본 자체를 없앰 → `core.md` "규칙 관리" + `check_rules.py` |
| `no-build-verification` | `core.md` "빌드 · 테스트 검증" (내용 그대로, 5단계에서 개정) |
| `logging` | `swift-style.md` |
| `text-style` · `preview-placement` | `swiftui.md` |
| `separate-dto-entity` · `dto-entity-server-align` · `contract-test-dto` | `api.md` (예시 축약) |
| `dummy-backend-store` | `dummy-backend.md` |
| (없음 — 코드 · 문서 · 사용자 결정에서 정리) | `architecture.md` · `concurrency.md` · `testing.md` · `cicd.md` · `core.md` 의 용어 · 작업 범위 · Git |

새 규칙은 코드에 이미 있는 패턴(`DIContainer`, `LoadableViewModel`, actor 사용, 빌드 설정)과 `docs/CI.md` · `docs/CD.md`, 사용자가 이전에 내린 결정(채팅 숨김 금지, `requiresDetail`, 같은 Bundle ID, 기존 스타일 우선)만 옮겼다. TDD 절차만 이번 계획에서 사용자가 요청해 추가했다.

### 정리한 충돌

- 이전 `text-style` 규칙은 "스타일이 없으면 `TextStyle` 에 추가" 였지만, 이후 사용자 결정(2026-11-13)은 "새 텍스트 스타일 · 색은 먼저 묻고 승인 시만" 이다. → `swiftui.md` 는 나중 결정을 따른다.

## 검증

| 항목 | 방법 | 결과 |
|---|---|---|
| Claude · Codex 가 같은 원본 참조 | `.claude/rules` 심볼릭 링크 · `AGENTS.md` 링크 · `check_rules.py` | ✅ |
| 사본 · 끊긴 경로 없음 | `check_rules.py` (사본 존재 · 맞는 파일 없는 `paths` · 표 누락을 실패 처리, 위반을 일부러 만들어 실패 확인) | ✅ |
| Claude 선택 로딩 | 헤드리스 세션 기록의 로드된 규칙 확인 — 아무 파일도 안 읽으면 `CLAUDE.md` · `core.md` 만, `Data/Common/DIContainer.swift` 를 읽으면 architecture · api · dummy-backend · swift-style · concurrency 추가 (swiftui · testing · cicd 는 로드 안 됨) | ✅ |
| Codex 선택 로딩 | 이 머신에 Codex CLI 가 없어 실행 확인은 못 함. `AGENTS.md` 지시 + 링크 검사만 | ⚠️ 정적 확인만 |
| CI/CD · 개발 정책과 일치 | `cicd.md` · `core.md` 를 `docs/CI.md` · `docs/CD.md` · 브랜치 보호 설정과 대조 | ✅ |

## 컨텍스트 변화 (Claude, 세션 시작 시 첫 호출 입력 토큰, claude-opus-5-5)

| | 토큰 |
|---|---|
| 규칙 없음 | 29,990 |
| 이전 — 규칙 전부 상시 로드 | 38,170 (규칙 8,180) |
| **지금 — `CLAUDE.md` + `core.md` 만 상시 로드** | **30,689 (규칙 약 700)** |

상시 로드되는 규칙 토큰이 약 91% 줄었다. 작업 파일을 읽으면 해당 규칙이 추가되므로 실제 작업에서는 이보다 늘어난다.
