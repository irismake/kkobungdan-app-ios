//
//  ChatRoom+Dummy.swift
//  Kkobungdan
//

import Foundation

/// 더미 서버가 저장하는 대화방. 대화방 상태는 요청·지원 상태와 별개로 저장하고,
/// 상태가 바뀌는 행동(지원·선택·완료·분쟁·취소)마다 `DummyBackendStore` 가 함께 갱신한다.
/// 목록의 마지막 메시지는 메시지 기록의 마지막 항목이다.
struct DummyChatRoom {
  var status: ChatRoomStatus
  var messages: [DummyChatMessage]
  var unreadCount: Int

  var lastMessage: String {
    messages.last?.text ?? ""
  }

  var lastMessageAt: Date {
    messages.last?.sentAt ?? .distantPast
  }
}

/// 더미 서버가 저장하는 메시지. `senderID` 가 nil 이면 시스템 메시지.
struct DummyChatMessage {
  let id: Int64
  let senderID: String?
  let text: String
  let sentAt: Date
}

/// 서버가 대화방에 남기는 시스템 메시지 문구. (서버 연동 시 서버 문구를 그대로 쓴다)
enum DummyChatSystemText {
  static let started = "지원으로 채팅이 시작되었어요."
  static let offerCancelled = "지원을 취소했어요. 대화가 자동으로 종료됩니다."
  static let notMatched = "매칭되지 않았습니다. 채팅이 자동으로 종료됩니다."
  static let waitingOrdererComplete = "행님의 완료 확인을 기다리고 있어요."
  static let waitingRunnerComplete = "꼬붕의 완료 확인을 기다리고 있어요."
  static let disputed = "분쟁중인 미션입니다. 분쟁이 해결될 때까지 잠시만 기다려 주세요."
  static let completed = "임무가 완료되었습니다. 정산이 곧 시작됩니다."
  static let missionCancelled = "종료된 미션입니다. 더 이상 진행할 수 없습니다."
  static let withdrawn = "탈퇴한 사용자입니다."
}

extension ChatRoom {
  /// 더미 메시지 한 줄. 보낸 사람은 대화방의 꼬붕(runner)·행님(orderer)·시스템 중 하나.
  private enum DummyLine {
    case runner(String, minutesAgo: Double)
    case orderer(String, minutesAgo: Double)
    case system(String, minutesAgo: Double)
  }

  /// offerID → 대화방. 대화방은 지원 1건당 1개라 `Offer.dummyList` 의 ID 를 쓴다.
  /// 상태는 상태 정책대로 직접 지정한다 (매칭 전: 대기중/취소, 매칭 후: 진행중/완료/분쟁중, 분쟁 실패: 취소).
  /// 모든 대화방은 지원 시각에 '채팅 시작' 시스템 메시지로 시작한다.
  static let dummyRoomByOfferID: [Int64: DummyChatRoom] = {
    let now = Date()
    let offerByID = Dictionary(uniqueKeysWithValues: Offer.dummyList.map { ($0.id, $0) })

    func room(
      _ offerID: Int64,
      _ status: ChatRoomStatus,
      unread: Int = 0,
      _ lines: [DummyLine]
    ) -> (Int64, DummyChatRoom)? {
      guard let offer = offerByID[offerID] else {
        return nil
      }
      let ordererID = Proposal.dummyOrdererIDByProposalID[offer.proposalID] ?? ""
      var nextID = offerID * 100
      func message(_ senderID: String?, _ text: String, _ sentAt: Date) -> DummyChatMessage {
        nextID += 1
        return DummyChatMessage(id: nextID, senderID: senderID, text: text, sentAt: sentAt)
      }
      var messages = [message(nil, DummyChatSystemText.started, offer.createdAt)]
      for line in lines {
        switch line {
        case let .runner(text, minutesAgo):
          messages.append(message(offer.runnerID, text, now.addingTimeInterval(-minutesAgo * 60)))
        case let .orderer(text, minutesAgo):
          messages.append(message(ordererID, text, now.addingTimeInterval(-minutesAgo * 60)))
        case let .system(text, minutesAgo):
          messages.append(message(nil, text, now.addingTimeInterval(-minutesAgo * 60)))
        }
      }
      return (offerID, DummyChatRoom(status: status, messages: messages, unreadCount: unread))
    }

    let rooms: [(Int64, DummyChatRoom)?] = [
      // 내 요청 3 '약국에서 약 수령' — 매칭 전, 지원자 4명 (대기 2, 지원 취소 1, 탈퇴 1)
      room(20, .waiting, unread: 1, [
        .runner("안녕하세요! 요청하신 시간에 도착할 수 있어요. 약국 위치 알려주세요.", minutesAgo: 20)
      ]),
      room(21, .waiting, unread: 1, [
        .runner("근처라서 바로 갈 수 있어요. 처방전은 어떻게 받으면 될까요?", minutesAgo: 35)
      ]),
      room(22, .cancelled, [
        .runner("안녕하세요! 오후에 시간 괜찮아요.", minutesAgo: 700),
        .system(DummyChatSystemText.offerCancelled, minutesAgo: 600)
      ]),
      room(23, .cancelled, [
        .runner("안녕하세요! 지원합니다.", minutesAgo: 700),
        .system(DummyChatSystemText.withdrawn, minutesAgo: 500)
      ]),
      // 내 지원 30 '택배 맡기기' — 매칭됨
      room(30, .inProgress, [
        .runner("안녕하세요! 오전에 바로 갈 수 있어요.", minutesAgo: 120),
        .orderer("내일 오전 10시에 편의점 앞에서 만나요.", minutesAgo: 90)
      ]),
      // 내 요청 5 '저녁 식사 픽업' — 선택 / 미선정 / 지원 취소
      room(40, .inProgress, unread: 1, [
        .runner("지원했어요! 저녁 7시까지 픽업 가능해요.", minutesAgo: 200),
        .orderer("네, 잘 부탁드려요.", minutesAgo: 100),
        .runner("픽업 완료하면 연락드릴게요!", minutesAgo: 50)
      ]),
      room(41, .cancelled, [
        .runner("지원했어요. 시간 맞춰 갈 수 있어요.", minutesAgo: 1450),
        .system(DummyChatSystemText.notMatched, minutesAgo: 1400)
      ]),
      room(42, .cancelled, [
        .runner("안녕하세요! 지원했어요.", minutesAgo: 1510),
        .system(DummyChatSystemText.offerCancelled, minutesAgo: 1500)
      ]),
      // 내 지원 50 '편의점 장보기 부탁' — 대기
      room(50, .waiting, [
        .runner("안녕하세요! 오후 3시에 도착할 수 있어요.", minutesAgo: 58),
        .orderer("지원 감사합니다. 오후 3시에 가게 입구에서 만나요!", minutesAgo: 55)
      ]),
      // 내 지원 51 '서류 전달' — 요청 취소(환불)로 미선정
      room(51, .cancelled, [
        .runner("서류 전달 가능해요!", minutesAgo: 2810),
        .system(DummyChatSystemText.notMatched, minutesAgo: 2800)
      ]),
      // 내 요청 8 '공항 픽업 부탁' — 완료
      room(60, .completed, [
        .runner("공항 도착했어요. 3번 게이트 앞이에요.", minutesAgo: 5100),
        .orderer("감사합니다!", minutesAgo: 5050),
        .system(DummyChatSystemText.completed, minutesAgo: 5000)
      ]),
      // 내 지원 70 '병원 처방전 대리 수령', 80 '주말 이사 짐 옮기기' — 매칭됨
      room(70, .inProgress, [
        .orderer("처방전은 접수처에서 이름 말하면 받을 수 있어요.", minutesAgo: 100),
        .runner("처방전 수령했어요. 어디로 가져다 드릴까요?", minutesAgo: 70)
      ]),
      room(80, .inProgress, [
        .runner("지원했어요! 주말 오전 가능해요.", minutesAgo: 50),
        .orderer("네, 잘 부탁드려요.", minutesAgo: 30)
      ]),
      // 내 요청 11 '도서관 도서 반납' — 완료
      room(81, .completed, [
        .runner("반납 완료했어요.", minutesAgo: 14100),
        .system(DummyChatSystemText.completed, minutesAgo: 14000)
      ]),
      // 내 지원 82 '세탁소 픽업' — 분쟁 실패 판정, 환불 완료 (지원 CANCELLED → 미션 취소)
      room(82, .cancelled, [
        .orderer("세탁소 영업시간 확인해 주세요.", minutesAgo: 17200),
        .system(DummyChatSystemText.disputed, minutesAgo: 17100),
        .system(DummyChatSystemText.missionCancelled, minutesAgo: 17000)
      ]),
      // 내 요청 14 '꽃집 화분 픽업' — 선택된 꼬붕이 분쟁 접수(분쟁중) / 미선택
      room(90, .disputed, unread: 1, [
        .runner("꽃집에 도착했어요.", minutesAgo: 60),
        .system(DummyChatSystemText.disputed, minutesAgo: 25)
      ]),
      room(91, .cancelled, [
        .runner("지원합니다!", minutesAgo: 2860),
        .system(DummyChatSystemText.notMatched, minutesAgo: 2800)
      ]),
      // 내 지원 100 '카페 원두 구매' — 내가 분쟁 접수(분쟁중)
      room(100, .disputed, [
        .orderer("원두 종류 확인 부탁드려요.", minutesAgo: 400),
        .system(DummyChatSystemText.disputed, minutesAgo: 300)
      ]),
      // 내 요청 16 '우체국 등기 발송' — 분쟁 완료 판정(완료)
      room(110, .completed, [
        .runner("등기 발송했어요.", minutesAgo: 7000),
        .system(DummyChatSystemText.disputed, minutesAgo: 6800),
        .system(DummyChatSystemText.completed, minutesAgo: 6500)
      ]),
      // 내 지원 120 '편의점 택배 수령' — 분쟁 실패 판정, 환불 대기(미션 취소)
      room(120, .cancelled, [
        .orderer("택배는 편의점 카운터에 맡겨주세요.", minutesAgo: 3000),
        .system(DummyChatSystemText.disputed, minutesAgo: 2500),
        .system(DummyChatSystemText.missionCancelled, minutesAgo: 2000)
      ]),
      // 내 요청 18 '반찬가게 픽업' — 분쟁 실패 판정, 환불 완료(미션 취소) / 미선택
      room(130, .cancelled, [
        .runner("반찬가게 도착했어요.", minutesAgo: 11500),
        .system(DummyChatSystemText.disputed, minutesAgo: 11200),
        .system(DummyChatSystemText.missionCancelled, minutesAgo: 11000)
      ]),
      room(131, .cancelled, [
        .runner("지원해요!", minutesAgo: 12940),
        .system(DummyChatSystemText.notMatched, minutesAgo: 12900)
      ]),
      // 내 지원 140 '중고 노트북 대리 구매' — 요청 신고 처리로 미선택(매칭 불성사)
      room(140, .cancelled, [
        .runner("안녕하세요! 지원합니다.", minutesAgo: 200),
        .system(DummyChatSystemText.notMatched, minutesAgo: 120)
      ])
    ]
    return Dictionary(uniqueKeysWithValues: rooms.compactMap { $0 })
  }()
}
