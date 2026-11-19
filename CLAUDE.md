# Kkobungdan iOS

## AI 규칙

규칙 본문은 Claude(`.claude/rules/*.md`) · Codex(`.codex/rules/*.md`)에 **동일 내용**으로 분리되어 있다. 수정 시 **해당 도메인 파일을 모두** 갱신한다.

| 규칙 | Claude | Codex |
|------|--------|--------|
| 통일 (최우선) | [`.claude/rules/00-ai-rules-unified.md`](.claude/rules/00-ai-rules-unified.md) | [`.codex/rules/00-ai-rules-unified.md`](.codex/rules/00-ai-rules-unified.md) |
| 텍스트 스타일 | [`.claude/rules/text-style.md`](.claude/rules/text-style.md) | [`.codex/rules/text-style.md`](.codex/rules/text-style.md) |
| 더미 백엔드 | [`.claude/rules/dummy-backend-store.md`](.claude/rules/dummy-backend-store.md) | [`.codex/rules/dummy-backend-store.md`](.codex/rules/dummy-backend-store.md) |
| DTO 스키마별 분리 / 엔티티 공유 | [`.claude/rules/separate-dto-entity.md`](.claude/rules/separate-dto-entity.md) | [`.codex/rules/separate-dto-entity.md`](.codex/rules/separate-dto-entity.md) |
| DTO·엔티티 서버 일치 | [`.claude/rules/dto-entity-server-align.md`](.claude/rules/dto-entity-server-align.md) | [`.codex/rules/dto-entity-server-align.md`](.codex/rules/dto-entity-server-align.md) |
| DTO 계약 테스트 등록 | [`.claude/rules/contract-test-dto.md`](.claude/rules/contract-test-dto.md) | [`.codex/rules/contract-test-dto.md`](.codex/rules/contract-test-dto.md) |
| 로깅 (`Logger`) | [`.claude/rules/logging.md`](.claude/rules/logging.md) | [`.codex/rules/logging.md`](.codex/rules/logging.md) |
| 프리뷰 코드 위치 | [`.claude/rules/preview-placement.md`](.claude/rules/preview-placement.md) | [`.codex/rules/preview-placement.md`](.codex/rules/preview-placement.md) |
| 빌드 검증 | [`.claude/rules/no-build-verification.md`](.claude/rules/no-build-verification.md) | [`.codex/rules/no-build-verification.md`](.codex/rules/no-build-verification.md) |

> Codex 인덱스: [`AGENTS.md`](AGENTS.md)
