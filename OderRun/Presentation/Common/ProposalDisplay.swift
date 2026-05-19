//
//  ProposalDisplay.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import SwiftUI

enum ProposalDisplay {
  private static let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
    formatter.dateFormat = "yyyy년 M월 d일"
    return formatter
  }()

  private static let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
    formatter.dateFormat = "a h시"
    return formatter
  }()

  private static let feeFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.locale = Locale(identifier: "ko_KR")
    return formatter
  }()

  static func dateString(_ date: Date) -> String {
    dateFormatter.string(from: date)
  }

  static func timeString(_ date: Date) -> String {
    timeFormatter.string(from: date)
  }

  static func feeString(_ fee: Int) -> String {
    let amount = feeFormatter.string(from: NSNumber(value: fee)) ?? "\(fee)"
    return "\(amount)원"
  }

  static func relativeTimeString(_ date: Date, now: Date = Date()) -> String {
    let diff = now.timeIntervalSince(date)
    switch diff {
    case ..<60:
      return "방금 전"
    case ..<3600:
      return "\(Int(diff / 60))분 전"
    case ..<86400:
      return "\(Int(diff / 3600))시간 전"
    case ..<(86400 * 7):
      return "\(Int(diff / 86400))일 전"
    default:
      let formatter = DateFormatter()
      formatter.locale = Locale(identifier: "ko_KR")
      formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
      formatter.dateFormat = "yyyy. MM. dd a h:mm"
      return formatter.string(from: date)
    }
  }

  static func appliedAtString(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
    formatter.dateFormat = "yyyy. M. d. a h:mm:ss '지원'"
    return formatter.string(from: date)
  }

  // MARK: - Badges

  static let waitingBadge = BadgeItem(text: "대기중", textColor: .blue500, bgColor: .blue000)
  static let newOfferBadge = BadgeItem(text: "새로운 지원 도착", textColor: .amber600, bgColor: .amber000)
  static let inProgressBadge = BadgeItem(text: "진행중", textColor: .indigo500, bgColor: .indigo000)
  static let completedBadge = BadgeItem(text: "완료", textColor: .emerald500, bgColor: .emerald000)
  static let cancelledBadge = BadgeItem(text: "취소", textColor: .gray500, bgColor: .gray100)
  static let unpaidBadge = BadgeItem(text: "미입금", textColor: .rose500, bgColor: .rose000)

  /// proposal / offer 상태로 배지를 결정한다.
  /// - myOfferStatus: 러너 본인이 이 proposal 에 제출한 offer 상태. 있으면 offer 상태가 우선.
  static func badges(
    proposal: Proposal,
    myOfferStatus: OfferStatus? = nil
  ) -> [BadgeItem] {
    if let myOfferStatus {
      switch myOfferStatus {
      case .waiting:
        return [waitingBadge]
      case .accepted:
        return [inProgressBadge]
      case .complete:
        return [completedBadge]
      case .rejected, .cancelled:
        return [cancelledBadge]
      }
    }

    switch proposal.status {
    case .posted:
      return [unpaidBadge]
    case .waiting:
      return [waitingBadge]
    case .offered:
      return [waitingBadge, newOfferBadge]
    case .matched:
      return [inProgressBadge]
    case .complete:
      return [completedBadge]
    case .cancelled:
      return [cancelledBadge]
    }
  }

  /// 내 요청(orderer) 활동 한 행에 대한 배지. proposal status 기반.
  static func badges(myProposal: MyProposal) -> [BadgeItem] {
    switch myProposal.status {
    case .posted:
      return [unpaidBadge]
    case .waiting:
      return [waitingBadge]
    case .offered:
      return [waitingBadge, newOfferBadge]
    case .matched:
      return [inProgressBadge]
    case .complete:
      return [completedBadge]
    case .cancelled:
      return [cancelledBadge]
    }
  }

  // TODO: 내 웨이팅 기록 배찌 기획 반영
  /// 웨이팅 기록(runner) 활동 한 행에 대한 배지. offer status 기반.
  static func badges(myOffer: MyOffer) -> [BadgeItem] {
    switch myOffer.status {
    case .waiting:
      return [waitingBadge]
    case .accepted:
      return [inProgressBadge]
    case .complete:
      return [completedBadge]
    case .rejected, .cancelled:
      return [cancelledBadge]
    }
  }
}
