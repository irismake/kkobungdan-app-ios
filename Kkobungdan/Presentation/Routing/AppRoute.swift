//
//  AppRoute.swift
//  Kkobungdan
//
//  Created by 김가희 on 4/27/26.
//
//  MainTabView 의 NavigationStack 에서 사용하는 push 라우팅 enum.
//  화면 빌더는 `MainTabView+Routing`, VM 팩토리는 `AppRouteFactory` 참고.
//

import Foundation

enum AppRoute: Hashable {
  /// 홈 탭에서 다른 사람의 의뢰를 탭한 경우 (지원하기 화면)
  case proposalDetail(proposalID: Int64)
  /// 의뢰자 본인의 의뢰 상세
  case myProposalDetail(proposalID: Int64)
  /// 러너 본인의 지원 상세 (활동 탭에서 진입)
  case offerDetail(proposalID: Int64, offerID: Int64)
  /// 의뢰자가 지원자 한 명을 검토하는 상세
  case runnerDetail(proposalID: Int64, offerID: Int64)
  /// 의뢰자가 자기 의뢰의 지원자 리스트를 보는 화면
  case runnerList(proposalID: Int64)
  /// 지원하기 → 계좌 등록 (임무 수행비 받을 계좌 입력)
  case offerAccount(proposalID: Int64)
  /// 계좌 등록 → 첫 인사(지원 메시지) 작성 + 실제 지원
  case offerMessage(proposalID: Int64)
  /// 지원하기 성공 직후 안내 화면
  case offerComplete(proposalID: Int64, offerID: Int64)
  /// 의뢰 신고 사유 선택 화면
  case report(proposalID: Int64)
  /// 신고 접수 완료 안내 화면
  case reportComplete
  /// 임무 중단(분쟁 제기) 사유 선택 화면
  case missionAbort(target: MissionAbortTarget)
  /// 임무 중단 신청 완료 안내 화면
  case missionAbortComplete
  /// 새 의뢰 작성 — 1단계: 제목/내용
  case addProposalDraft
  /// 새 의뢰 작성 — 2단계: 날짜/시간
  case addProposalDateTime(draft: AddProposalDraft)
  /// 새 의뢰 작성 — 3단계: 웨이팅비 입력 + 등록
  case addProposalFee(draft: AddProposalDraft)
  /// 홈 헤더 알림 버튼 → 알림 목록
  case notifications
  /// 채팅 상세. 대화방은 지원 1건당 1개라 roomID 는 지원(offer) ID 와 같다.
  case chatRoom(roomID: Int64)
}
