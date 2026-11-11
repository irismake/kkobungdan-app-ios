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
    case let .offerAccount(proposalID):
      OfferAccountView(
        viewModel: AppRouteFactory.makeOfferAccountViewModel(proposalID: proposalID),
        onBack: { self.popLast(path: path) },
        onRegistered: {
          path.wrappedValue.append(.offerMessage(proposalID: proposalID))
        }
      )
      .navigationBarBackButtonHidden(true)
    case let .offerMessage(proposalID):
      OfferMessageView(
        viewModel: AppRouteFactory.makeOfferMessageViewModel(proposalID: proposalID),
        onBack: { self.popLast(path: path) },
        onApplied: { offerID in
          path.wrappedValue.append(.offerComplete(proposalID: proposalID, offerID: offerID))
        }
      )
      .navigationBarBackButtonHidden(true)
    case let .offerComplete(proposalID, offerID):
      OfferCompleteView(
        onConfirm: {
          path.wrappedValue.removeAll()
        },
        onViewHistory: {
          path.wrappedValue.removeAll()
          self.activitySegment = .runner
          self.activityPath = [.offerDetail(proposalID: proposalID, offerID: offerID)]
          self.selectedTab = .activity
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
        }
      )
      .navigationBarBackButtonHidden(true)
    case let .offerDetail(proposalID, offerID):
      OfferDetailView(
        viewModel: AppRouteFactory.makeOfferDetailViewModel(
          proposalID: proposalID,
          offerID: offerID
        ),
        onBack: { self.popLast(path: path) },
        onAbort: {
          path.wrappedValue.append(.missionAbort(target: .offer(offerID: offerID)))
        }
      )
      .navigationBarBackButtonHidden(true)
    case let .runnerDetail(proposalID, offerID):
      OfferDetailView(
        viewModel: AppRouteFactory.makeOfferDetailViewModel(
          proposalID: proposalID,
          offerID: offerID
        ),
        onBack: { self.popLast(path: path) },
        onAbort: {
          path.wrappedValue.append(.missionAbort(target: .offer(offerID: offerID)))
        }
      )
      .navigationBarBackButtonHidden(true)
    case let .runnerList(proposalID):
      OfferListView(
        viewModel: AppRouteFactory.makeOfferListViewModel(proposalID: proposalID),
        onBack: { self.popLast(path: path) },
        onAccepted: {
          path.wrappedValue = [.myProposalDetail(proposalID: proposalID)]
        },
        onSelectRunner: { proposalID, offerID in
          path.wrappedValue.append(.runnerDetail(proposalID: proposalID, offerID: offerID))
        }
      )
      .navigationBarBackButtonHidden(true)
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
    }
  }
}
