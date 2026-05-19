# OderRun iOS

## AI 규칙 통일 (최우선)

프로젝트의 모든 AI 규칙은 **반드시 통일**되어야 한다.

- **단일 출처 쌍**: `CLAUDE.md`와 `.cursor/rules/*.mdc`에 **동일한 내용**을 유지한다.
- **규칙 추가·수정·삭제 시**: 한쪽만 바꾸지 말고 **두 곳 모두** 같은 섹션·문구로 반영한다.
- **내용 불일치 금지**: 한 파일에만 존재하는 규칙을 두지 않는다. (도메인별 `.mdc` 분리는 가능하나, `CLAUDE.md`에도 동일 섹션이 있어야 한다.)
- **충돌 시**: 이 통일 규칙을 최우선으로 따르고, 어긋난 쪽을 맞춘다.

## 텍스트 스타일 규칙

텍스트 스타일은 `View+TextStyle.swift`의 `TextStyle` enum에 정의되어 있다.

1. **정의된 스타일 우선 사용**: 텍스트를 렌더링할 때는 `.textStyle(.xxx)` 를 우선 사용한다.

2. **스타일이 없을 경우 추가**: 필요한 스타일이 없으면 `TextStyle` enum에 새로운 케이스를 추가한다.

3. **kerning만 다를 경우 override 사용**: 기존 스타일과 `fontName`, `fontSize`, `lineHeight`가 동일하고 kerning만 다를 경우, 새 스타일을 추가하지 않고 기존 스타일에 `.kerning(X)`을 체이닝하여 구현한다.
   ```swift
   // 예시: caption2(Regular 12/20/-0.15)와 fontName/fontSize/lineHeight가 같고 kerning만 다른 경우
   Text("...")
     .textStyle(.caption2)
     .kerning(-0.2)
   ```

## 더미 백엔드 (`DummyBackendStore`) 규칙

더미(Test) 환경에서는 `DummyBackendStore`가 **실제 백엔드의 단일 DB + 트랜잭션 cascade** 역할만 한다.

### `DummyBackendStore` (인메모리 저장소)

- proposal / offer / mission 목 데이터의 **조회·생성·수정·상태 전이**를 이 actor 한곳에서 관리한다.
- 연관 엔티티 cascade(예: proposal 취소 → offer REJECTED, mission 생성 → offer ACCEPTED/REJECTED + proposal MATCHED), 유효성 검사(`RepositoryError`), ID 발급도 **store에만** 둔다.
- 상태 전이·비즈니스 규칙을 `Test*RepositoryImpl` 여러 곳에 흩어두지 않는다.

### `Test*RepositoryImpl` (Repository 어댑터)

- `ProposalRepositoryProtocol` 등 프로토콜 구현, **지연 시뮬레이션**(`Task.sleep`), `DummySession`·문자열 날짜 등 **요청 매핑** 후 `store`에 위임만 한다.
- store 밖에 두는 것: 네트워크 지연, 세션/사용자 ID 주입, DTO 파싱. **데이터 상태 변경 로직은 넣지 않는다.**

### 새 더미 기능 추가 시

1. 상태·cascade가 필요하면 `DummyBackendStore`에 메서드 추가.
2. `Test*RepositoryImpl`은 sleep + 매핑 + `await store.xxx` 호출만 추가.
