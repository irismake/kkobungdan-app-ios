//
//  DisputeEvidence+Dummy.swift
//  Kkobungdan
//

import Foundation

extension DisputeEvidence {
  /// proposalID → 분쟁 증빙. 분쟁중(DISPUTED) 더미 건의 신청자를 정한다.
  /// - 14 '꽃집 화분 픽업': 꼬붕(성실한치타)이 신청 → 내 요청 상세에서 '중단당함'
  /// - 15 '카페 원두 구매': 내가(꼬붕) 신청 → 내 지원 상세에서 '내가 신청'
  static let dummyByProposalID: [Int64: DisputeEvidence] = {
    let now = Date()
    return [
      14: DisputeEvidence(
        id: 1,
        proposalID: 14,
        offerID: 90,
        actorID: "user-r001",
        reasonQuestionID: 1,
        detailReason: "현장에서 요청 내용이 변경되었어요.",
        createdAt: now.addingTimeInterval(-25 * 60)
      ),
      15: DisputeEvidence(
        id: 2,
        proposalID: 15,
        offerID: 100,
        actorID: DummySession.currentUserID,
        reasonQuestionID: 1,
        detailReason: "가게가 문을 닫아 구매할 수 없었어요.",
        createdAt: now.addingTimeInterval(-300 * 60)
      )
    ]
  }()
}
