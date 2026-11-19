# Kkobungdan iOS

## AI 규칙

규칙 본문은 Codex(`.codex/rules/*.md`) · Claude(`.claude/rules/*.md`)에 **동일 내용**으로 분리되어 있다. 수정 시 **해당 도메인 파일을 모두** 갱신한다.

**Codex 는 이 파일만 자동으로 읽는다. 작업을 시작하기 전에 아래 표의 `.codex/rules/*.md` 를 모두 읽고 그대로 따른다.**

| 규칙 | Codex | Claude |
|------|--------|--------|
| 통일 (최우선) | [`.codex/rules/00-ai-rules-unified.md`](.codex/rules/00-ai-rules-unified.md) | [`.claude/rules/00-ai-rules-unified.md`](.claude/rules/00-ai-rules-unified.md) |
| 텍스트 스타일 | [`.codex/rules/text-style.md`](.codex/rules/text-style.md) | [`.claude/rules/text-style.md`](.claude/rules/text-style.md) |
| 더미 백엔드 | [`.codex/rules/dummy-backend-store.md`](.codex/rules/dummy-backend-store.md) | [`.claude/rules/dummy-backend-store.md`](.claude/rules/dummy-backend-store.md) |
| DTO 스키마별 분리 / 엔티티 공유 | [`.codex/rules/separate-dto-entity.md`](.codex/rules/separate-dto-entity.md) | [`.claude/rules/separate-dto-entity.md`](.claude/rules/separate-dto-entity.md) |
| DTO·엔티티 서버 일치 | [`.codex/rules/dto-entity-server-align.md`](.codex/rules/dto-entity-server-align.md) | [`.claude/rules/dto-entity-server-align.md`](.claude/rules/dto-entity-server-align.md) |
| DTO 계약 테스트 등록 | [`.codex/rules/contract-test-dto.md`](.codex/rules/contract-test-dto.md) | [`.claude/rules/contract-test-dto.md`](.claude/rules/contract-test-dto.md) |
| 로깅 (`Logger`) | [`.codex/rules/logging.md`](.codex/rules/logging.md) | [`.claude/rules/logging.md`](.claude/rules/logging.md) |
| 프리뷰 코드 위치 | [`.codex/rules/preview-placement.md`](.codex/rules/preview-placement.md) | [`.claude/rules/preview-placement.md`](.claude/rules/preview-placement.md) |
| 빌드 검증 | [`.codex/rules/no-build-verification.md`](.codex/rules/no-build-verification.md) | [`.claude/rules/no-build-verification.md`](.claude/rules/no-build-verification.md) |

> Claude 인덱스: [`CLAUDE.md`](CLAUDE.md)
