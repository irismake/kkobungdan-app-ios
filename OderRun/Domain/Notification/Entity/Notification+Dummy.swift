//
//  Notification+Dummy.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

extension AppNotification {
  static let dummyList: [AppNotification] = {
    let now = Date()
    return [
      AppNotification(
        id: 1,
        title: "새 지원이 도착했어요",
        body: "민수형님이 '약국에서 약 수령' 요청에 지원했어요.",
        createdAt: now.addingTimeInterval(-20 * 60),
        isRead: false
      ),
      AppNotification(
        id: 2,
        title: "매칭 완료",
        body: "'저녁 식사 픽업' 요청의 러너로 지현님이 확정됐어요.",
        createdAt: now.addingTimeInterval(-2 * 3600),
        isRead: false
      ),
      AppNotification(
        id: 3,
        title: "전달 완료 처리됨",
        body: "'택배 맡기기' 전달 완료가 접수됐어요. 의뢰자 수령 확인을 기다리고 있어요.",
        createdAt: now.addingTimeInterval(-86400),
        isRead: true
      ),
      AppNotification(
        id: 4,
        title: "정산 완료",
        body: "지난 주 심부름비 18,000원이 정산됐어요.",
        createdAt: now.addingTimeInterval(-2 * 86400),
        isRead: true
      ),
      AppNotification(
        id: 5,
        title: "프로모션 안내",
        body: "이번 주 심야 시간대 심부름비 10% 추가 적립 이벤트가 진행 중입니다.",
        createdAt: now.addingTimeInterval(-3 * 86400),
        isRead: true
      )
    ]
  }()

  static var dummy: AppNotification {
    dummyList[0]
  }
}
