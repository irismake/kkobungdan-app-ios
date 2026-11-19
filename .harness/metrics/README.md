# 하네스 지표

하네스 도입 효과를 숫자로 비교하기 위한 수집 도구. 기준선 결과는 [docs/harness/01-baseline.md](../../docs/harness/01-baseline.md).

## 수집 방법

```sh
python3 .harness/metrics/collect_github.py [--since 2026-11-19T05:00] [--until ...]   # PR · CI (gh 인증 필요)
python3 .harness/metrics/collect_agents.py [--since 2026-11-19T05:00] [--until ...]   # Claude · Codex 로컬 세션 로그
```

- 둘 다 **조회만** 한다. 결과는 표준 출력(Markdown)과 `out/*.json`(gitignore)에 남는다.
- 시간은 UTC. 하네스 도입 시점은 `2026-11-19T05:00` (1단계 시작).

| 파일 | 내용 | 커밋 |
|---|---|---|
| `collect_github.py` | 머지된 PR · `iOS CI` 실행 이력 집계 | ✅ |
| `collect_agents.py` | `~/.claude/projects/<레포>/` · `~/.codex/sessions/` 의 이 레포 세션 집계 | ✅ |
| `out/` | 실행 결과 원본 (세션 ID · 세션별 수치) | ❌ |

## 지표 정의

### 자동 수집

| 지표 | 정의 | 출처 |
|---|---|---|
| 작업 PR 수 · 유형 | 머지된 PR 중 승격·역반영(`dev`·`staging`·`main` 출발) 제외. 유형은 제목 접두사, 없으면 브랜치 접두사 | GitHub |
| fix 비율 | fix / (feat + fix + refactor). **재작업 대리 지표** | GitHub |
| PR 당 커밋 수 | 중앙값. 한 작업 안에서 고친 횟수의 대리 지표 | GitHub |
| 첫 커밋 → 머지 | 중앙값. PR 을 머지 직전에 여는 경우가 많아 "PR 생성 → 머지" 대신 쓴다 | GitHub |
| CI 성공률 · 최초 통과율 | PR 검사: 출발 브랜치별 첫 실행 / 큐: PR 번호별 첫 실행이 성공한 비율. 취소된 실행 제외 | GitHub Actions |
| 실패한 job | 실패한 실행의 job 이름별 횟수 | GitHub Actions |
| 세션 수 · 작업 시간 | 10분 넘는 공백을 뺀 시간 | 로컬 세션 로그 |
| 토큰 | 입력(캐시 쓰기·읽기 포함) · 출력 · 캐시 적중 비율. Claude 는 `message.id` 로 중복 제거, Codex 는 세션 누적값의 마지막 값 | 로컬 세션 로그 |
| 도구 · 서브에이전트 호출 | `tool_use` 개수, 그중 `Agent`/`Task` | 로컬 세션 로그 |

### 수집이 어려운 지표

| 지표 | 이유 | 대신 쓰는 것 |
|---|---|---|
| 요구사항 충족도 · 리뷰 지적 · 재작업 | 판정 주체가 사람, 자동 수집 불가 | 8단계(실사용)에서 필요하면 그때 정한다 |
| 비용(달러) | 모델·요금제별 단가가 다르고 바뀐다 | 토큰 수로 비교 |

## 주의

- **Claude Code 는 오래된 세션 로그를 자동 삭제한다** (`cleanupPeriodDays`, 기본 30일). 기준선은 남아 있는 세션만으로 계산했다.
- 1인 프로젝트라 표본이 작다. 비율보다 건수 · 사례를 함께 본다.
- 세션 로그의 프롬프트 · 응답 내용은 저장하지 않는다. 숫자만 남긴다. Secret 이 섞일 수 있는 원문을 `out/` 에도 쓰지 않는다.
