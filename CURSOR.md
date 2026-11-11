# Kkobungdan iOS

## AI 규칙

규칙 본문은 Cursor(`.cursor/rules/*.mdc`) · Claude(`.claude/rules/*.md`) · Codex(`.codex/rules/*.md`)에 **동일 내용**으로 분리되어 있다. 수정 시 **해당 도메인 파일을 모두** 갱신한다.

| 규칙 | Cursor | Claude | Codex |
|------|--------|--------|--------|
| 통일 (최우선) | [`.cursor/rules/00-ai-rules-unified.mdc`](.cursor/rules/00-ai-rules-unified.mdc) | [`.claude/rules/00-ai-rules-unified.md`](.claude/rules/00-ai-rules-unified.md) | [`.codex/rules/00-ai-rules-unified.md`](.codex/rules/00-ai-rules-unified.md) |
| 텍스트 스타일 | [`.cursor/rules/text-style.mdc`](.cursor/rules/text-style.mdc) | [`.claude/rules/text-style.md`](.claude/rules/text-style.md) | [`.codex/rules/text-style.md`](.codex/rules/text-style.md) |
| 더미 백엔드 | [`.cursor/rules/dummy-backend-store.mdc`](.cursor/rules/dummy-backend-store.mdc) | [`.claude/rules/dummy-backend-store.md`](.claude/rules/dummy-backend-store.md) | [`.codex/rules/dummy-backend-store.md`](.codex/rules/dummy-backend-store.md) |
| DTO 스키마별 분리 / 엔티티 공유 | [`.cursor/rules/separate-dto-entity.mdc`](.cursor/rules/separate-dto-entity.mdc) | [`.claude/rules/separate-dto-entity.md`](.claude/rules/separate-dto-entity.md) | [`.codex/rules/separate-dto-entity.md`](.codex/rules/separate-dto-entity.md) |
| DTO·엔티티 서버 일치 | [`.cursor/rules/dto-entity-server-align.mdc`](.cursor/rules/dto-entity-server-align.mdc) | [`.claude/rules/dto-entity-server-align.md`](.claude/rules/dto-entity-server-align.md) | [`.codex/rules/dto-entity-server-align.md`](.codex/rules/dto-entity-server-align.md) |
| DTO 계약 테스트 등록 | [`.cursor/rules/contract-test-dto.mdc`](.cursor/rules/contract-test-dto.mdc) | [`.claude/rules/contract-test-dto.md`](.claude/rules/contract-test-dto.md) | [`.codex/rules/contract-test-dto.md`](.codex/rules/contract-test-dto.md) |
| 로깅 (`Logger`) | [`.cursor/rules/logging.mdc`](.cursor/rules/logging.mdc) | [`.claude/rules/logging.md`](.claude/rules/logging.md) | [`.codex/rules/logging.md`](.codex/rules/logging.md) |
| 프리뷰 코드 위치 | [`.cursor/rules/preview-placement.mdc`](.cursor/rules/preview-placement.mdc) | [`.claude/rules/preview-placement.md`](.claude/rules/preview-placement.md) | [`.codex/rules/preview-placement.md`](.codex/rules/preview-placement.md) |

> Claude 인덱스: [`CLAUDE.md`](CLAUDE.md) · Codex 인덱스: [`AGENTS.md`](AGENTS.md)
