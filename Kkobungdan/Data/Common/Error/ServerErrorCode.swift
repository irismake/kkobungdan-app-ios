//
//  ServerErrorCode.swift
//  Kkobungdan
//
//  Created by 김가희 on 7/23/26.
//

import Foundation

/// 서버가 `ErrorResponse.error.code` 로 내려주는 값 중 iOS API 가 사용하는 값(43종).
/// 분기는 상태코드·message 가 아니라 이 값으로만 한다. (message 문구는 예고 없이 바뀐다)
/// 정본: 서버 저장소 `docs/api-spec/error-codes.md` — 기준일 2026-08-27
enum ServerErrorCode: String, Decodable, CaseIterable {
  case unknown = "UNKNOWN"

  // MARK: - 토큰 실패

  /// 401. 만료·변조·종류 불일치·헤더 없음·sub 없음이 모두 이 코드로 온다.
  /// 만료가 섞여 있으므로 이 코드만 보고 로그아웃하면 안 된다. (`/v1/auth/refresh` 응답일 때만 복구 불가)
  case invalidToken = "INVALID_TOKEN"

  // MARK: - 입력값 오류

  /// 400. 필수 약관 미동의도 이 코드로 온다. `details` 에 `"필드명: 사유"` 가 담긴다.
  case validationError = "VALIDATION_ERROR"
  /// 400. deadline 형식 오류.
  case invalidDateTimeFormat = "INVALID_DATE_TIME_FORMAT"
  /// 400. 마감 시각이 현재 시각 이전.
  case proposalDeadlineInvalid = "PROPOSAL_DEADLINE_INVALID"
  /// 400. 심부름비가 1000원 미만.
  case proposalErrandFeeInvalid = "PROPOSAL_ERRAND_FEE_INVALID"
  /// 400. 의뢰·지원 생성 전에 정산 계좌 등록이 필요함.
  case settlementAccountRequired = "SETTLEMENT_ACCOUNT_REQUIRED"
  /// 400. 인증번호 불일치.
  case phoneVerificationCodeMismatch = "PHONE_VERIFICATION_CODE_MISMATCH"
  /// 400. 인증번호 만료.
  case phoneVerificationExpired = "PHONE_VERIFICATION_EXPIRED"

  // MARK: - 가입·로그인 흐름

  /// 409. 이미 가입된 휴대폰 번호.
  case phoneAlreadyExists = "PHONE_ALREADY_EXISTS"
  /// 404. 인증 요청 내역 없음.
  case phoneVerificationNotFound = "PHONE_VERIFICATION_NOT_FOUND"
  /// 429. 인증번호 발송 제한(5분당 3회).
  case phoneVerificationSendRateLimited = "PHONE_VERIFICATION_SEND_RATE_LIMITED"

  // MARK: - 대상이 사라짐

  /// 404.
  case proposalNotFound = "PROPOSAL_NOT_FOUND"
  /// 404.
  case offerNotFound = "OFFER_NOT_FOUND"
  /// 404. 단, `/v1/auth/refresh` 응답이면 세션 복구 불가.
  case userNotFound = "USER_NOT_FOUND"
  /// 404.
  case notificationNotFound = "NOTIFICATION_NOT_FOUND"
  /// 404.
  case proposalReportNotFound = "PROPOSAL_REPORT_NOT_FOUND"
  /// 404.
  case disputeEvidenceNotFound = "DISPUTE_EVIDENCE_NOT_FOUND"

  // MARK: - 상태 충돌

  /// 409.
  case proposalNotEditable = "PROPOSAL_NOT_EDITABLE"
  /// 409.
  case proposalNotCancellable = "PROPOSAL_NOT_CANCELLABLE"
  /// 409.
  case proposalNotOpen = "PROPOSAL_NOT_OPEN"
  /// 409.
  case proposalNotMatchable = "PROPOSAL_NOT_MATCHABLE"
  /// 409.
  case proposalNotUpdatable = "PROPOSAL_NOT_UPDATABLE"
  /// 409.
  case proposalNotReportable = "PROPOSAL_NOT_REPORTABLE"
  /// 409.
  case offerNotAcceptable = "OFFER_NOT_ACCEPTABLE"
  /// 409.
  case offerNotCancellable = "OFFER_NOT_CANCELLABLE"
  /// 409.
  case offerNotUpdatable = "OFFER_NOT_UPDATABLE"
  /// 409. 이미 해당 요청에 지원함.
  case duplicateOffer = "DUPLICATE_OFFER"
  /// 409. 이미 해당 요청을 신고함.
  case duplicateProposalReport = "DUPLICATE_PROPOSAL_REPORT"
  /// 409. 이미 처리된 신고.
  case proposalReportNotReviewable = "PROPOSAL_REPORT_NOT_REVIEWABLE"
  /// 409. 진행 중인 요청·지원·환불·정산이 있어 탈퇴 불가(포괄 코드).
  case userWithdrawalBlocked = "USER_WITHDRAWAL_BLOCKED"
  /// 409. 입금 확인 중인 요청이 있어 탈퇴 불가.
  case userWithdrawalBlockedProposalDeposit = "USER_WITHDRAWAL_BLOCKED_PROPOSAL_DEPOSIT"
  /// 409. 진행 중인 요청이 있어 탈퇴 불가.
  case userWithdrawalBlockedProposal = "USER_WITHDRAWAL_BLOCKED_PROPOSAL"
  /// 409. 진행 중인 지원이 있어 탈퇴 불가.
  case userWithdrawalBlockedOffer = "USER_WITHDRAWAL_BLOCKED_OFFER"
  /// 409. 완료되지 않은 환불이 있어 탈퇴 불가.
  case userWithdrawalBlockedRefund = "USER_WITHDRAWAL_BLOCKED_REFUND"
  /// 409. 완료되지 않은 수행비 지급이 있어 탈퇴 불가.
  case userWithdrawalBlockedPayout = "USER_WITHDRAWAL_BLOCKED_PAYOUT"

  // MARK: - 권한 없음

  /// 403. 인증은 정상이고 이 동작을 할 자격만 없다. 로그아웃 대상이 아니다.
  case forbidden = "FORBIDDEN"
  /// 403. 본인의 요청은 신고 불가.
  case proposalSelfReportNotAllowed = "PROPOSAL_SELF_REPORT_NOT_ALLOWED"
  /// 400. 본인의 요청에는 지원 불가.
  case selfOfferNotAllowed = "SELF_OFFER_NOT_ALLOWED"

  // MARK: - 서버 오류

  /// 500. `details` 는 운영 환경에서 항상 nil.
  case internalServerError = "INTERNAL_SERVER_ERROR"
  /// 500. 서버 설정 문제 — 발생하면 백엔드에 알린다.
  case smsSenderNotConfigured = "SMS_SENDER_NOT_CONFIGURED"
  /// 코드 카탈로그를 우회한 예외에 대한 서버측 방어. 현재 발생 경로는 없다.
  /// 문구가 "요청을 처리할 수 없습니다." 로 고정이라 화면별 fallback 이 더 구체적이다.
  case httpError = "HTTP_ERROR"

  // MARK: - 클라이언트 버그 신호

  /// 404. 존재하지 않는 경로(URL 오타). 리소스 없음(`proposalNotFound` 등)과 다르다.
  case notFound = "NOT_FOUND"
  /// 405. 허용되지 않은 HTTP 메서드.
  case methodNotAllowed = "METHOD_NOT_ALLOWED"
}

extension ServerErrorCode {
  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawValue = try container.decode(String.self)
    self = ServerErrorCode(rawValue: rawValue) ?? .unknown
  }

  /// 정상 사용에서는 발생하지 않는, 클라이언트 요청 자체가 잘못됐다는 신호.
  /// 사용자에게 보여줄 문구가 아니므로 서버 message 를 노출하지 않는다.
  var isClientBugSignal: Bool {
    switch self {
    case .notFound, .methodNotAllowed:
      return true
    default:
      return false
    }
  }
}
