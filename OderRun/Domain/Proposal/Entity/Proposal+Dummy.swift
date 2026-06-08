//
//  Proposal+Dummy.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

extension Proposal {
  /// 더미 백엔드에서 proposal 소유자(orderer) 조회용. `Proposal` 엔티티에는 포함하지 않는다.
  static let dummyOrdererIDByProposalID: [Int64: String] = [
    1: "user-a001",
    2: "user-a002",
    3: DummySession.currentUserID,
    4: "user-a001",
    5: DummySession.currentUserID,
    6: "user-a002",
    7: DummySession.currentUserID,
    8: DummySession.currentUserID,
    9: "user-a002",
    10: "user-a003",
    11: DummySession.currentUserID,
    12: "user-a004",
    13: DummySession.currentUserID
  ]

  static let dummyList: [Proposal] = {
    let now = Date()
    return [
      Proposal(
        id: 1,
        title: "편의점 장보기 부탁",
        content: "GS25에서 저지방 우유 1L와 식빵을 사서 아파트 경비실에 맡겨주세요.",
        deadline: now.addingTimeInterval(2 * 86400),
        errandFee: 4000,
        status: .offered
      ),
      Proposal(
        id: 2,
        title: "강아지 산책 대신",
        content: "주말에 30분 정도 강아지와 산책해 주세요. 산책로는 한강공원 이촌지구입니다.",
        deadline: now.addingTimeInterval(3 * 86400),
        errandFee: 10000,
        status: .offered
      ),
      Proposal(
        id: 3,
        title: "약국에서 약 수령",
        content: "온누리약국에서 미리 주문한 처방전 받은 약을 대신 수령해 주세요.",
        deadline: now.addingTimeInterval(86400),
        errandFee: 3500,
        status: .offered
      ),
      Proposal(
        id: 4,
        title: "택배 맡기기",
        content: "문 앞에 둔 택배 상자 2개를 CU 편의점에 맡겨주세요.",
        deadline: now.addingTimeInterval(-86400),
        errandFee: 2500,
        status: .matched
      ),
      Proposal(
        id: 5,
        title: "저녁 식사 픽업",
        content: "교대역 쉐이크쉑 치즈버거 세트 2개 픽업 후 자택으로 배달 부탁드립니다.",
        deadline: now.addingTimeInterval(-2 * 3600),
        errandFee: 8000,
        status: .matched
      ),
      Proposal(
        id: 6,
        title: "서류 전달",
        content: "강남구청 민원실에 서류 1건 제출해 주세요. 번호표 대기 필요.",
        deadline: now.addingTimeInterval(-2 * 86400),
        errandFee: 5000,
        status: .cancelled
      ),
      Proposal(
        id: 7,
        title: "장미꽃 구매 배달",
        content: "꽃시장 근처에서 빨간 장미 20송이 구매 후 회사로 배달 부탁드립니다.",
        deadline: now.addingTimeInterval(4 * 86400),
        errandFee: 6000,
        status: .holding
      ),
      Proposal(
        id: 8,
        title: "공항 픽업 부탁",
        content: "인천공항 1터미널에서 가족 픽업 후 자택까지 동행 부탁드립니다.",
        deadline: now.addingTimeInterval(-4 * 86400),
        errandFee: 5000,
        status: .complete
      ),
      Proposal(
        id: 9,
        title: "병원 처방전 대리 수령",
        content: "강남세브란스병원에서 처방전 1건 대리 수령 후 자택 전달 부탁드립니다.",
        deadline: now.addingTimeInterval(-7 * 86400),
        errandFee: 3000,
        status: .matched
      ),
      Proposal(
        id: 10,
        title: "주말 이사 짐 옮기기",
        content: "1.5톤 분량의 박스 정리 후 트럭에 적재 부탁드립니다. 시작 전 연락 주세요.",
        deadline: now.addingTimeInterval(2 * 86400),
        errandFee: 12000,
        status: .matched
      ),
      Proposal(
        id: 11,
        title: "도서관 도서 반납",
        content: "관악구립도서관에 도서 3권 반납 부탁드립니다.",
        deadline: now.addingTimeInterval(-10 * 86400),
        errandFee: 2000,
        status: .complete
      ),
      Proposal(
        id: 12,
        title: "세탁소 픽업",
        content: "역삼동 크린토피아에서 세탁물 수령 후 자택 전달 부탁드립니다.",
        deadline: now.addingTimeInterval(-12 * 86400),
        errandFee: 3500,
        status: .complete
      ),
      Proposal(
        id: 13,
        title: "도서관 자료 검색",
        content: "국립중앙도서관에서 특정 논문 자료 복사본 받아주세요.",
        deadline: now.addingTimeInterval(5 * 86400),
        errandFee: 4500,
        status: .posted
      )
    ]
  }()

  static var dummy: Proposal {
    dummyList[0]
  }
}
