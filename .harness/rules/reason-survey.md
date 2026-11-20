---
paths:
  - "Kkobungdan/Presentation/Report/**"
  - "Kkobungdan/Presentation/Withdraw/**"
  - "Kkobungdan/Presentation/MissionAbort/**"
  - "Kkobungdan/Common/Components/ReasonSurveyLayout.swift"
  - "Kkobungdan/Data/Report/**"
  - "Kkobungdan/Data/DisputeSurvey/**"
  - "Kkobungdan/Data/User/**"
  - "Kkobungdan/Domain/Report/**"
  - "Kkobungdan/Domain/DisputeSurvey/**"
  - "Kkobungdan/Domain/User/**"
---

# 사유 입력 (분쟁 · 신고 · 탈퇴)

대상 엔드포인트 4개가 같은 정책을 쓴다: `POST /v1/proposal/{id}/dispute`, `POST /v1/offer/{offerId}/dispute`, `POST /v1/proposal/{id}/reports`, `DELETE /v1/user`.

- `reasonQuestionId` 는 필수. `detailReason` 은 스키마상 optional 이지만, **선택한 사유의 `requiresDetail` 이 true 면 서버가 400 `VALIDATION_ERROR`(`details: "detailReason"`)로 거부**한다. 공백만 있는 값도 거부한다.
- 서버는 사유 목록 응답의 `requiresDetail` 과 같은 값으로 판정한다. 이 조건은 OpenAPI 스펙 · 계약 테스트로는 보이지 않는다.
- 클라이언트도 `requiresDetail` 로 판단한다. ViewModel 의 `canSubmit` · `isDetailRequired` 가드는 UX 용으로 유지하고 서버 검증을 이중 방어로 둔다. **문구("기타" 등)로 필수 여부를 추측하는 코드로 되돌리지 않는다.**
- 상세 사유 길이: 서버는 신고 · 탈퇴 500자, 분쟁 무제한. 클라이언트는 세 화면 모두 `detailMaxLength = 500` 으로 통일했다.
- 탈퇴(`DELETE /v1/user`)는 요청 본문 자체가 필수다. 본문 없이 호출하면 400.
