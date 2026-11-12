//
//  ChatRoom+Dummy.swift
//  Kkobungdan
//

import Foundation

/// 더미 서버가 저장하는 대화방. 대화방 상태는 요청·지원 상태와 별개로 저장하고,
/// 상태가 바뀌는 행동(지원·선택·완료·분쟁·취소)마다 `DummyBackendStore` 가 함께 갱신한다.
struct DummyChatRoom {
  let status: ChatRoomStatus
  let lastMessage: String
  let lastMessageAt: Date
  let unreadCount: Int
}

extension ChatRoom {
  /// offerID → 대화방. 대화방은 지원 1건당 1개라 `Offer.dummyList` 의 ID 를 쓴다.
  /// 상태는 상태 정책대로 직접 지정한다 (매칭 전: 대기중/취소, 매칭 후: 진행중/완료/분쟁중, 분쟁 실패: 취소).
  static let dummyRoomByOfferID: [Int64: DummyChatRoom] = {
    let now = Date()
    func room(_ status: ChatRoomStatus, _ text: String, minutesAgo: Double, unread: Int = 0) -> DummyChatRoom {
      DummyChatRoom(
        status: status,
        lastMessage: text,
        lastMessageAt: now.addingTimeInterval(-minutesAgo * 60),
        unreadCount: unread
      )
    }
    return [
      // 내 요청 3 '약국에서 약 수령' — 매칭 전, 지원자 3명 (대기 2, 지원 취소 1)
      20: room(.waiting, "안녕하세요! 요청하신 시간에 도착할 수 있어요. 약국 위치 알려주세요.", minutesAgo: 20, unread: 1),
      21: room(.waiting, "근처라서 바로 갈 수 있어요. 처방전은 어떻게 받으면 될까요?", minutesAgo: 35, unread: 1),
      22: room(.cancelled, "지원을 취소했어요. 메시지 전송이 종료됩니다.", minutesAgo: 600),
      // 내 지원 30 '택배 맡기기' — 매칭됨
      30: room(.inProgress, "내일 오전 10시에 편의점 앞에서 만나요.", minutesAgo: 90),
      // 내 요청 5 '저녁 식사 픽업' — 선택 / 미선정 / 지원 취소
      40: room(.inProgress, "픽업 완료하면 연락드릴게요!", minutesAgo: 50, unread: 2),
      41: room(.cancelled, "다른 지원자와 매칭되어 대화가 종료되었어요.", minutesAgo: 1500),
      42: room(.cancelled, "지원을 취소했어요. 메시지 전송이 종료됩니다.", minutesAgo: 1560),
      // 내 지원 50 '편의점 장보기 부탁' — 대기
      50: room(.waiting, "지원 감사합니다. 오후 3시에 가게 입구에서 만나요!", minutesAgo: 55),
      // 내 지원 51 '서류 전달' — 요청 취소(환불)로 미선정
      51: room(.cancelled, "요청이 취소되어 모집과 지원이 종료됐어요.", minutesAgo: 2800),
      // 내 요청 8 '공항 픽업 부탁' — 완료
      60: room(.completed, "정산이 완료됐어요.", minutesAgo: 5000),
      // 내 지원 70 '병원 처방전 대리 수령', 80 '주말 이사 짐 옮기기' — 매칭됨
      70: room(.inProgress, "처방전 수령했어요. 어디로 가져다 드릴까요?", minutesAgo: 70),
      80: room(.inProgress, "매칭이 확정되었어요.", minutesAgo: 120),
      // 내 요청 11 '도서관 도서 반납' — 완료
      81: room(.completed, "임무가 완료되었어요. 대화 기록을 확인할 수 있어요.", minutesAgo: 14000),
      // 내 지원 82 '세탁소 픽업' — 분쟁 실패 판정, 환불 완료 (지원 CANCELLED → 취소)
      82: room(.cancelled, "검토 결과에 따라 행님에게 환불이 완료됐어요.", minutesAgo: 17000),
      // 내 요청 14 '꽃집 화분 픽업' — 선택된 꼬붕이 분쟁 접수(분쟁중) / 미선택
      90: room(.disputed, "임무 중단이 접수되었어요. 관리자 검토를 기다리고 있어요.", minutesAgo: 25, unread: 1),
      91: room(.cancelled, "다른 지원자와 매칭되어 대화가 종료되었어요.", minutesAgo: 2800),
      // 내 지원 100 '카페 원두 구매' — 내가 분쟁 접수(분쟁중)
      100: room(.disputed, "임무 중단을 신청했어요. 관리자 검토를 기다리고 있어요.", minutesAgo: 300),
      // 내 요청 16 '우체국 등기 발송' — 분쟁 완료 판정(완료)
      110: room(.completed, "검토 결과 임무가 완료로 처리되었어요.", minutesAgo: 6500),
      // 내 지원 120 '편의점 택배 수령' — 분쟁 실패 판정, 환불 대기(취소)
      120: room(.cancelled, "검토 결과 임무가 실패로 처리되어 행님에게 환불이 진행돼요.", minutesAgo: 2000),
      // 내 요청 18 '반찬가게 픽업' — 분쟁 실패 판정, 환불 완료(취소) / 미선택
      130: room(.cancelled, "검토 결과에 따른 환불이 완료됐어요.", minutesAgo: 11000),
      131: room(.cancelled, "다른 지원자와 매칭되어 대화가 종료되었어요.", minutesAgo: 12900),
      // 내 지원 140 '중고 노트북 대리 구매' — 요청 신고 처리로 미선택(취소)
      140: room(.cancelled, "요청이 신고 처리되어 대화가 종료되었어요.", minutesAgo: 120)
    ]
  }()
}
