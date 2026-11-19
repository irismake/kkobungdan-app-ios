//
//  AppRouter+Routing.swift
//  Kkobungdan
//
//  AppRoute → 화면 push 빌더. VM 은 `AppRouteFactory` 로 조립한다.
//

import SwiftUI

extension AppRouter {
  @ViewBuilder
  func destination(for route: AppRoute, path: Binding<[AppRoute]>) -> some View {
    switch route {
    case let .proposalDetail(proposalID):
      ProposalDetailView(
        viewModel: AppRouteFactory.makeProposalDetailViewModel(proposalID: proposalID),
        onBack: { self.popLast(path: path) },
        onOffer: {
          path.wrappedValue.append(.offerAccount(proposalID: proposalID))
        },
        onMine: {
          // 홈에서 탭한 요청이 내 요청이면 내 요청 상세로 라우트를 교체한다.
          if !path.wrappedValue.isEmpty {
            path.wrappedValue[path.wrappedValue.count - 1] = .myProposalDetail(proposalID: proposalID)
          }
        },
        onMyOffer: { offerID in
          // 홈에서 탭한 요청에 내 지원이 있으면 내 지원 상세로 라우트를 교체한다.
          if !path.wrappedValue.isEmpty {
            path.wrappedValue[path.wrappedValue.count - 1] = .offerDetail(proposalID: proposalID, offerID: offerID)
          }
        },
        onReport: {
          path.wrappedValue.append(.report(proposalID: proposalID))
        }
      )
      .navigationBarBackButtonHidden(true)
    case let .report(proposalID):
      ReportView(
        viewModel: AppRouteFactory.makeReportViewModel(proposalID: proposalID),
        onClose: { self.popLast(path: path) },
        onSubmitted: {
          path.wrappedValue.append(.reportComplete)
        }
      )
      .navigationBarBackButtonHidden(true)
    case .reportComplete:
      ReportCompleteView(
        onHome: {
          path.wrappedValue.removeAll()
          self.selectedTab = .home
        }
      )
      .navigationBarBackButtonHidden(true)
    case let .missionAbort(target):
      MissionAbortView(
        viewModel: AppRouteFactory.makeMissionAbortViewModel(target: target),
        onClose: { self.popLast(path: path) },
        onSubmitted: {
          path.wrappedValue.append(.missionAbortComplete)
        }
      )
      .navigationBarBackButtonHidden(true)
    case .missionAbortComplete:
      MissionAbortCompleteView(
        onHome: {
          path.wrappedValue.removeAll()
          self.selectedTab = .home
        }
      )
      .navigationBarBackButtonHidden(true)
    case let .myProposalDetail(proposalID):
      MyProposalDetailView(
        viewModel: AppRouteFactory.makeMyProposalDetailViewModel(proposalID: proposalID),
        onBack: { self.popLast(path: path) },
        onShowRunners: {
          path.wrappedValue.append(.runnerList(proposalID: proposalID))
        },
        onAbort: {
          path.wrappedValue.append(.missionAbort(target: .proposal(proposalID: proposalID)))
        },
        onOpenChat: { room in
          path.wrappedValue.append(.chatRoom(roomID: room.id))
        }
      )
      .navigationBarBackButtonHidden(true)
    case .offerAccount, .offerMessage, .offerComplete, .offerDetail, .runnerDetail, .runnerList:
      offerDestination(for: route, path: path)
    case .addProposalDraft, .addProposalDateTime, .addProposalFee:
      addProposalDestination(for: route, path: path)
    case .notifications:
      NotificationView(
        viewModel: AppRouteFactory.makeNotificationViewModel(),
        onSelect: { payload in
          Task { await self.route(push: payload) }
        },
        onBack: { self.popLast(path: path) }
      )
      .navigationBarBackButtonHidden(true)
    case let .chatRoom(roomID):
      ChatRoomView(
        viewModel: AppRouteFactory.makeChatRoomViewModel(roomID: roomID),
        onBack: { self.popLast(path: path) },
        onOpenMission: { room in
          switch room.myRole {
          case .orderer:
            path.wrappedValue.append(.myProposalDetail(proposalID: room.proposalID))
          case .runner:
            path.wrappedValue.append(.offerDetail(proposalID: room.proposalID, offerID: room.id))
          }
        }
      )
      .navigationBarBackButtonHidden(true)
    }
  }
}
