# OderRun iOS

## AI 규칙

규칙 본문은 Claude(`.claude/rules/*.md`)와 Cursor(`.cursor/rules/*.mdc`)에 **동일 내용**으로 분리되어 있다. 수정 시 **해당 도메인 파일을 모두** 갱신한다.

| 규칙 | Claude | Cursor |
|------|--------|--------|
| 통일 (최우선) | [`.claude/rules/00-ai-rules-unified.md`](.claude/rules/00-ai-rules-unified.md) | [`.cursor/rules/00-ai-rules-unified.mdc`](.cursor/rules/00-ai-rules-unified.mdc) |
| 텍스트 스타일 | [`.claude/rules/text-style.md`](.claude/rules/text-style.md) | [`.cursor/rules/text-style.mdc`](.cursor/rules/text-style.mdc) |
| 더미 백엔드 | [`.claude/rules/dummy-backend-store.md`](.claude/rules/dummy-backend-store.md) | [`.cursor/rules/dummy-backend-store.mdc`](.cursor/rules/dummy-backend-store.mdc) |
| 별도 DTO/엔티티 | [`.claude/rules/separate-dto-entity.md`](.claude/rules/separate-dto-entity.md) | [`.cursor/rules/separate-dto-entity.mdc`](.cursor/rules/separate-dto-entity.mdc) |
| 로깅 (`Logger`) | [`.claude/rules/logging.md`](.claude/rules/logging.md) | [`.cursor/rules/logging.mdc`](.cursor/rules/logging.mdc) |

> Cursor 인덱스: [`CURSOR.md`](CURSOR.md)
