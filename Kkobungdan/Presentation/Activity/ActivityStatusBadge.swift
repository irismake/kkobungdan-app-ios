//
//  ActivityStatusBadge.swift
//  Kkobungdan
//
//  proposal / offer 상태(status)를 화면 배지(BadgeItem)로 매핑한다.
//  날짜·금액 포맷팅은 `DisplayFormatter` 참고.
//

import SwiftUI

enum ActivityStatusBadge {
  static let waitingBadge = BadgeItem(text: "대기중", textColor: .blue500, bgColor: .blue000)
  static let newOfferBadge = BadgeItem(text: "새로운 지원 도착", textColor: .amber600, bgColor: .amber000)
  static let inProgressBadge = BadgeItem(text: "진행중", textColor: .indigo500, bgColor: .indigo000)
  static let completedBadge = BadgeItem(text: "완료", textColor: .emerald500, bgColor: .emerald000)
  static let cancelledBadge = BadgeItem(text: "취소", textColor: .gray500, bgColor: .gray100)
  static let unpaidBadge = BadgeItem(text: "미입금", textColor: .rose500, bgColor: .rose000)
  static let disputedBadge = BadgeItem(text: "분쟁중", textColor: .rose800, bgColor: .rose000, iconName: "icon_dispute")

  /// proposal / offer 상태로 배지를 결정한다.
  /// - myOfferStatus: 러너 본인이 이 proposal 에 제출한 offer 상태. 있으면 offer 상태가 우선.
  static func badges(
    proposal: Proposal,
    myOfferStatus: OfferStatus? = nil
  ) -> [BadgeItem] {
    badges(status: proposal.status, myOfferStatus: myOfferStatus)
  }

  /// 상세(ProposalDetail) 응답용 오버로드. 목록 응답과 배지 규칙이 동일하다.
  static func badges(
    proposal: ProposalDetail,
    myOfferStatus: OfferStatus? = nil
  ) -> [BadgeItem] {
    badges(status: proposal.status, myOfferStatus: myOfferStatus)
  }

  private static func badges(
    status: ProposalStatus,
    myOfferStatus: OfferStatus? = nil
  ) -> [BadgeItem] {
    if let myOfferStatus {
      switch myOfferStatus {
      case .waiting:
        return [waitingBadge]
      case .accepted, .runnerCompleted:
        return [inProgressBadge]
      case .allCompleted:
        return [completedBadge]
      case .disputed:
        return [disputedBadge]
      case .rejected, .cancelled, .resolved:
        return [cancelledBadge]
      }
    }

    switch status {
    case .holding:
      return [unpaidBadge]
    case .posted:
      return [waitingBadge]
    case .offered:
      return [waitingBadge, newOfferBadge]
    case .matched, .orderCompleted:
      return [inProgressBadge]
    case .allCompleted:
      return [completedBadge]
    case .disputed:
      return [disputedBadge]
    case .cancelled, .resolved:
      return [cancelledBadge]
    }
  }

  /// 내 요청(orderer) 활동 한 행에 대한 배지. proposal status 기반.
  static func badges(myProposal: MyProposal) -> [BadgeItem] {
    switch myProposal.status {
    case .holding:
      return [unpaidBadge]
    case .posted:
      return [waitingBadge]
    case .offered:
      return [waitingBadge, newOfferBadge]
    case .matched, .orderCompleted:
      return [inProgressBadge]
    case .allCompleted:
      return [completedBadge]
    case .disputed:
      return [disputedBadge]
    case .cancelled, .resolved:
      return [cancelledBadge]
    }
  }

  // TODO: 내 웨이팅 기록 배찌 기획 반영
  /// 웨이팅 기록(runner) 활동 한 행에 대한 배지. offer status 기반.
  static func badges(myOffer: MyOffer) -> [BadgeItem] {
    switch myOffer.status {
    case .waiting:
      return [waitingBadge]
    case .accepted, .runnerCompleted:
      return [inProgressBadge]
    case .allCompleted:
      return [completedBadge]
    case .disputed:
      return [disputedBadge]
    case .rejected, .cancelled, .resolved:
      return [cancelledBadge]
    }
  }
}
