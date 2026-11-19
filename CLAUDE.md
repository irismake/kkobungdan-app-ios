# Kkobungdan iOS — Claude Code

프로젝트 규칙 원본은 **`.harness/rules/`** 이고 Codex 와 같은 파일을 쓴다. `.claude/rules` 는 이 폴더의 심볼릭 링크라 자동으로 로드된다.

- `core.md` 는 항상 로드된다.
- 나머지 규칙은 파일 맨 위 `paths` 에 맞는 파일을 읽을 때 로드된다. 작업 유형별 목록은 [`AGENTS.md`](AGENTS.md) 의 표와 같다.
- 경로로 잡히지 않는 작업(예: 파일을 아직 열지 않은 설계 질문)이면 표를 보고 해당 규칙을 직접 읽는다.

Claude 전용 규칙은 현재 없다. 생기면 이 파일에만 적는다.
