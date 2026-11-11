//
//  ChatRoom+Dummy.swift
//  Kkobungdan
//

import Foundation

extension ChatRoom {
  /// '성수동 행님' 대화는 내가 지원자(myOffer 있음), 나머지는 내가 요청자인 대화.
  static let dummyList: [ChatRoom] = {
    let now = Date()
    func make(
      _ id: Int64,
      _ name: String,
      _ title: String,
      _ message: String,
      minutesAgo: Double,
      _ proposalStatus: ProposalStatus,
      myOffer: OfferStatus? = nil,
      unread: Int = 0
    ) -> ChatRoom {
      ChatRoom(
        id: id,
        counterpartName: name,
        proposalTitle: title,
        lastMessage: message,
        lastMessageAt: now.addingTimeInterval(-minutesAgo * 60),
        proposalStatus: proposalStatus,
        myOfferStatus: myOffer,
        unreadCount: unread
      )
    }
    let bakery = "성수 베이커리 소금빵 웨이팅"
    let gopchang = "강남역 곱창전골 웨이팅"
    return [
      make(1, "성수동 행님", bakery, "검토 결과에 따른 지급과 환불이 완료됐어요. 사유: 요청 내용과 다름 · 현장에서 요청 내용이 변경되었어요.", minutesAgo: 1, .disputed, myOffer: .disputed),
      make(2, "성수동 행님", bakery, "지원을 취소했어요. 메시지 전송이 종료됩니다.", minutesAgo: 2, .offered, myOffer: .cancelled),
      make(3, "카야잼", bakery, "환불이 완료됐어요.", minutesAgo: 3, .refunded),
      make(4, "카야잼", bakery, "정산이 완료됐어요.", minutesAgo: 4, .allCompleted),
      make(5, "윤슬", bakery, "정산이 완료됐어요.", minutesAgo: 5, .allCompleted),
      make(6, "카야잼", bakery, "모집을 재개했어요.", minutesAgo: 6, .posted),
      make(7, "카야잼", bakery, "요청이 취소되어 모집과 지원이 종료됐어요.", minutesAgo: 7, .cancelled),
      make(8, "카야잼", bakery, "임무가 완료되었어요. 대화 기록을 확인할 수 있어요.", minutesAgo: 8, .allCompleted),
      make(9, "성수동 행님", bakery, "매칭이 확정되었어요.", minutesAgo: 9, .matched, myOffer: .accepted),
      make(10, "성수동 행님", bakery, "다른 지원자와 매칭되어 대화가 종료되었어요.", minutesAgo: 10, .matched, myOffer: .rejected),
      make(11, "카야잼", bakery, "매칭이 확정되었어요.", minutesAgo: 11, .matched),
      make(12, "카야잼", bakery, "매칭이 확정되었어요.", minutesAgo: 12, .orderCompleted),
      make(13, "카야잼", bakery, "안녕하세요! 요청하신 시간에 도착할 수 있어요. 만날 장소를 알려주세요.", minutesAgo: 13, .offered, unread: 1),
      make(14, "윤슬", bakery, "안녕하세요! 요청하신 시간에 도착할 수 있어요. 만날 장소를 알려주세요.", minutesAgo: 14, .offered, unread: 1),
      make(15, "성수동 행님", bakery, "지원 감사합니다. 오후 3시에 가게 입구에서 만나요!", minutesAgo: 15, .offered, myOffer: .waiting),
      make(16, "카야잼", gopchang, "안녕하세요! 근처에 있어서 오후 3시부터 줄 설 수 있어요. 3명 자리 맞으실까요?", minutesAgo: 45, .offered, unread: 1),
      make(17, "윤슬", gopchang, "안녕하세요, 시간 맞춰 도착할 수 있어요. 만날 장소를 알려주세요!", minutesAgo: 75, .offered, unread: 1)
    ]
  }()
}
