//
//  Notification+Dummy.swift
//  Kkobungdan
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

extension AppNotification {
  /// deepLink 의 proposalID·offerID 는 `Proposal.dummyList`·`Offer.dummyList` 와 맞춰야 한다.
  /// 알림 탭 시 `AppRouter.route(push:)` 가 수신자 입장(요청자/지원자)으로 화면을 연다.
  static let dummyList: [AppNotification] = {
    let now = Date()
    return [
      AppNotification(
        id: 1,
        title: "새 지원이 도착했어요",
        body: "성실한치타님이 '약국에서 약 수령' 요청에 지원했어요.",
        createdAt: now.addingTimeInterval(-20 * 60),
        isRead: false,
        // 수신: 요청자(나) — proposal 3 은 내 요청, offer 20 은 성실한치타(user-r001)의 지원
        deepLink: PushPayload(type: .offerNew, offerID: 20, proposalID: 3)
      ),
      AppNotification(
        id: 2,
        title: "매칭 완료",
        body: "'주말 이사 짐 옮기기' 요청의 러너로 확정됐어요.",
        createdAt: now.addingTimeInterval(-2 * 3600),
        isRead: false,
        // 수신: 선택된 지원자(나) — proposal 10 에서 내 지원 offer 80 이 수락됨
        deepLink: PushPayload(type: .offerAccepted, offerID: 80, proposalID: 10)
      ),
      AppNotification(
        id: 3,
        title: "만남 확인",
        body: "이웃주민1님이 '택배 맡기기' 만남을 확인했어요.",
        createdAt: now.addingTimeInterval(-86400),
        isRead: true,
        // 수신: 상대방(나 = 러너) — proposal 4 의 요청자는 이웃주민1, 내 지원 offer 30 이 수락된 상태
        deepLink: PushPayload(type: .meetingConfirmed, offerID: 30, proposalID: 4)
      ),
      AppNotification(
        id: 4,
        title: "정산 완료",
        body: "지난 주 심부름비 18,000원이 정산됐어요.",
        createdAt: now.addingTimeInterval(-2 * 86400),
        isRead: true,
        deepLink: nil
      ),
      AppNotification(
        id: 5,
        title: "프로모션 안내",
        body: "이번 주 심야 시간대 심부름비 10% 추가 적립 이벤트가 진행 중입니다.",
        createdAt: now.addingTimeInterval(-3 * 86400),
        isRead: true,
        deepLink: nil
      )
    ]
  }()

  static var dummy: AppNotification {
    dummyList[0]
  }
}
