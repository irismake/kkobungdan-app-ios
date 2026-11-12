//
//  ChatRoom+Dummy.swift
//  Kkobungdan
//

import Foundation

/// 더미 대화방의 마지막 메시지. 대화방 자체는 `DummyBackendStore` 가 지원(offer) 데이터로 만든다.
struct DummyChatMessage {
  let text: String
  let sentAt: Date
  let unreadCount: Int
}

extension ChatRoom {
  /// offerID → 마지막 메시지. `Offer.dummyList` 의 ID 와 맞춘다.
  /// 여기 없는 대화방(새로 지원한 경우 등)은 지원 시각·기본 문구로 채운다.
  static let dummyLastMessageByOfferID: [Int64: DummyChatMessage] = {
    let now = Date()
    func message(_ text: String, minutesAgo: Double, unread: Int = 0) -> DummyChatMessage {
      DummyChatMessage(text: text, sentAt: now.addingTimeInterval(-minutesAgo * 60), unreadCount: unread)
    }
    return [
      // 내 요청 3 '약국에서 약 수령' — 지원자 3명
      20: message("안녕하세요! 요청하신 시간에 도착할 수 있어요. 약국 위치 알려주세요.", minutesAgo: 20, unread: 1),
      21: message("근처라서 바로 갈 수 있어요. 처방전은 어떻게 받으면 될까요?", minutesAgo: 35, unread: 1),
      22: message("다른 지원자와 매칭되어 대화가 종료되었어요.", minutesAgo: 600),
      // 내 지원 30 '택배 맡기기' — 매칭됨
      30: message("내일 오전 10시에 편의점 앞에서 만나요.", minutesAgo: 90),
      // 내 요청 5 '저녁 식사 픽업' — 선택 / 미선정 / 지원 취소
      40: message("픽업 완료하면 연락드릴게요!", minutesAgo: 50, unread: 2),
      41: message("다른 지원자와 매칭되어 대화가 종료되었어요.", minutesAgo: 1500),
      42: message("지원을 취소했어요. 메시지 전송이 종료됩니다.", minutesAgo: 1560),
      // 내 지원 50 '편의점 장보기 부탁' — 대기
      50: message("지원 감사합니다. 오후 3시에 가게 입구에서 만나요!", minutesAgo: 55),
      // 내 지원 51 '서류 전달' — 요청 취소
      51: message("요청이 취소되어 모집과 지원이 종료됐어요.", minutesAgo: 2800),
      // 내 요청 8 '공항 픽업 부탁' — 완료
      60: message("정산이 완료됐어요.", minutesAgo: 5000),
      // 내 지원 70 '병원 처방전 대리 수령', 80 '주말 이사 짐 옮기기' — 매칭됨
      70: message("처방전 수령했어요. 어디로 가져다 드릴까요?", minutesAgo: 70),
      80: message("매칭이 확정되었어요.", minutesAgo: 120),
      // 내 요청 11 '도서관 도서 반납' — 완료
      81: message("임무가 완료되었어요. 대화 기록을 확인할 수 있어요.", minutesAgo: 14000),
      // 내 지원 82 '세탁소 픽업' — 환불
      82: message("환불이 완료됐어요.", minutesAgo: 17000)
    ]
  }()
}
