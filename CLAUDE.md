# Kkobungdan iOS

## AI 규칙

규칙 본문은 Claude(`.claude/rules/*.md`)와 Cursor(`.cursor/rules/*.mdc`)에 **동일 내용**으로 분리되어 있다. 수정 시 **해당 도메인 파일을 모두** 갱신한다.

| 규칙 | Claude | Cursor |
|------|--------|--------|
| 통일 (최우선) | [`.claude/rules/00-ai-rules-unified.md`](.claude/rules/00-ai-rules-unified.md) | [`.cursor/rules/00-ai-rules-unified.mdc`](.cursor/rules/00-ai-rules-unified.mdc) |
| 텍스트 스타일 | [`.claude/rules/text-style.md`](.claude/rules/text-style.md) | [`.cursor/rules/text-style.mdc`](.cursor/rules/text-style.mdc) |
| 더미 백엔드 | [`.claude/rules/dummy-backend-store.md`](.claude/rules/dummy-backend-store.md) | [`.cursor/rules/dummy-backend-store.mdc`](.cursor/rules/dummy-backend-store.mdc) |
| DTO 스키마별 분리 / 엔티티 공유 | [`.claude/rules/separate-dto-entity.md`](.claude/rules/separate-dto-entity.md) | [`.cursor/rules/separate-dto-entity.mdc`](.cursor/rules/separate-dto-entity.mdc) |
| DTO·엔티티 서버 일치 | [`.claude/rules/dto-entity-server-align.md`](.claude/rules/dto-entity-server-align.md) | [`.cursor/rules/dto-entity-server-align.mdc`](.cursor/rules/dto-entity-server-align.mdc) |
| DTO 계약 테스트 등록 | [`.claude/rules/contract-test-dto.md`](.claude/rules/contract-test-dto.md) | [`.cursor/rules/contract-test-dto.mdc`](.cursor/rules/contract-test-dto.mdc) |
| 로깅 (`Logger`) | [`.claude/rules/logging.md`](.claude/rules/logging.md) | [`.cursor/rules/logging.mdc`](.cursor/rules/logging.mdc) |

> Cursor 인덱스: [`CURSOR.md`](CURSOR.md)
