---
name: api-sync
description: 꼬붕단 서버 OpenAPI 스펙 변경을 iOS DTO · 엔티티 · 계약 테스트에 반영한다. 서버 API 추가 · 변경, 계약 테스트 실패, "서버 계약 업데이트" 요청 때 사용.
---

# 서버 계약 반영

## 입력

서버 변경 내용 (또는 "최신 스펙 반영"). 스펙은 `Scripts/sync-openapi.py` 로 받는다.

## 절차

1. **스펙 받기**: `python3 Scripts/sync-openapi.py` 는 로컬 `Secrets.Debug.xcconfig` 의 개발 서버 주소 · docs 인증으로 스테이징 서버에 접속한다. **실행 전에 사용자에게 확인**하고, 사용자가 이미 실행했으면 결과 파일을 쓴다. 인증값을 출력 · 기록하지 않는다.
2. **변경 목록 만들기**: `git diff KkobungdanTests/Contract/` 와 `contract.lock.json` ↔ `contract.current.json` 차이로 스키마별 필드 추가 · 삭제 · 타입 · optional 변경을 표로 정리한다.
3. **영향 찾기**: 바뀐 스키마를 쓰는 DTO (`DecodeContract("<스키마>"` 로 찾음) → `toDomain()` → 엔티티 → 화면.
4. **반영** (`api.md`)
   - DTO 필드 · `CodingKeys` · optional 을 스펙과 똑같이.
   - 엔티티는 앱이 실제로 쓰는 필드만. 안 쓰는 새 필드는 `toDomain()` TODO 한 줄.
   - 새 스키마를 앱이 쓰면 DTO 를 만들고 계약 테스트에 등록, 안 쓰면 `knownUnregistered…` 목록에 사유와 함께 추가.
   - enum 값이 늘면 알 수 없는 값에서 화면이 깨지지 않는지 확인한다.
   - `requiresDetail` 처럼 스펙에 안 보이는 서버 검증은 `reason-survey.md` 참고.
5. **테스트**: `./Scripts/test.sh OpenAPIContractTests` → 통과하면 전체.
6. **기준선 승인**: 변경을 반영한 뒤 사용자 확인을 받아 `python3 Scripts/sync-openapi.py --accept` (lock 갱신).

## 출력 (보고)

- 스키마별 변경 표 (필드 · 변경 · 앱 반영 여부 · 이유)
- 바꾼 DTO · 엔티티 · 화면
- 계약 테스트 · 전체 테스트 결과
- 동작이 바뀌는 지점 (필수 → 선택, 상태값 추가 등)

## 완료 조건

- 계약 테스트가 통과한다.
- 모든 변경 필드가 반영 또는 TODO · 미사용 사유로 정리됐다.
- lock 갱신은 사용자 확인 후에만 했다.
