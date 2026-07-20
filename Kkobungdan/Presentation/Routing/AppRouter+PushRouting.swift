//
//  AppRouter+PushRouting.swift
//  Kkobungdan
//
//  푸시 payload → 탭 전환 + push 스택 변환. (알림 정책 문서 "이벤트별 알림 계약" 기준)
//

import Foundation
import OSLog

private let pushRoutingLogger = Logger(subsystem: "com.kkobungdan.Kkobungdan", category: "Push")

extension AppRouter {
  /// 푸시 배너 탭으로 들어온 payload 를 해당 화면으로 라우팅한다.
  /// `meeting_confirmed` 처럼 요청자·지원자 양쪽에 같은 타입으로 오는 이벤트는
  /// proposal 상세의 `ordererID` 와 내 userID 를 비교해 입장을 판별한다.
  @MainActor
  func route(push payload: PushPayload) async {
    switch payload.type {
    case .offerNew:
      // 수신: 요청자 — 내 의뢰 상세로
      showMyProposal(proposalID: payload.proposalID)
    case .offerSubmitted, .offerAccepted:
      // 수신: 지원자 본인 — 내 지원 상세로
      showMyOffer(proposalID: payload.proposalID, offerID: payload.offerID)
    case .offerRejected:
      // 수신: 탈락 지원자 — payload 의 offer_id 가 "선택된 지원자"의 것이라
      // 내 지원 상세를 특정할 수 없다. 수행 기록의 '취소' 카테고리(REJECTED 포함)로 이동.
      showActivityRoot(segment: .runner, filter: .cancelled)
    case .meetingConfirmed, .executionCompleted, .disputeRaised:
      // 요청자·지원자 양쪽에 같은 타입으로 오는 이벤트 → 역할 판별 후 라우팅
      await routeByRole(payload: payload)
    }
  }

  @MainActor
  private func routeByRole(payload: PushPayload) async {
    do {
      let detail = try await FetchProposalDetailUseCase(repository: DIContainer.proposalRepository)
        .execute(id: payload.proposalID)
      if detail.ordererID == TokenStorage.shared.userID {
        showMyProposal(proposalID: payload.proposalID)
      } else {
        showMyOffer(proposalID: payload.proposalID, offerID: payload.offerID)
      }
    } catch {
      pushRoutingLogger.warning("푸시 라우팅용 proposal 조회 실패, 활동 탭으로 대체: \(error)")
      showActivityRoot(segment: .orderer, filter: .all)
    }
  }

  @MainActor
  private func showMyProposal(proposalID: Int64) {
    selectedTab = .activity
    activitySegment = .orderer
    activityFilter = .all
    activityPath = [.myProposalDetail(proposalID: proposalID)]
  }

  @MainActor
  private func showMyOffer(proposalID: Int64, offerID: Int64) {
    selectedTab = .activity
    activitySegment = .runner
    activityFilter = .all
    activityPath = [.offerDetail(proposalID: proposalID, offerID: offerID)]
  }

  @MainActor
  private func showActivityRoot(segment: ActivitySegment, filter: ActivityStatusFilter) {
    selectedTab = .activity
    activitySegment = segment
    activityFilter = filter
    activityPath = []
  }
}
