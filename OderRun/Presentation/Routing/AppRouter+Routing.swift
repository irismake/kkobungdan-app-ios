//
//  AppRouter+Routing.swift
//  OderRun
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
          path.wrappedValue.append(.addOffer(proposalID: proposalID))
        },
        onMine: {
          // 홈에서 탭한 요청이 내 요청이면 내 요청 상세로 라우트를 교체한다.
          if !path.wrappedValue.isEmpty {
            path.wrappedValue[path.wrappedValue.count - 1] = .myProposalDetail(proposalID: proposalID)
          }
        }
      )
      .navigationBarBackButtonHidden(true)
    case let .addOffer(proposalID):
      AddOfferView(
        viewModel: AppRouteFactory.makeAddOfferViewModel(proposalID: proposalID),
        onBack: { self.popLast(path: path) },
        onApplied: {
          path.wrappedValue.append(.offerComplete(proposalID: proposalID))
        }
      )
      .navigationBarBackButtonHidden(true)
    case .offerComplete:
      OfferCompleteView(
        onConfirm: {
          path.wrappedValue.removeAll()
        },
        onViewHistory: {
          // home segment 에는 offer 가 보이는 곳이 없으므로 activity 탭으로 보낸다.
          // 거기서 본인 offer 카드를 탭하면 `.offerDetail(proposalID:offerID:)` 로 진입.
          path.wrappedValue.removeAll()
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
        }
      )
      .navigationBarBackButtonHidden(true)
    case let .offerDetail(proposalID, offerID):
      OfferDetailView(
        viewModel: AppRouteFactory.makeOfferDetailViewModel(
          proposalID: proposalID,
          offerID: offerID
        ),
        onBack: { self.popLast(path: path) }
      )
      .navigationBarBackButtonHidden(true)
    case let .runnerDetail(proposalID, offerID):
      OfferDetailView(
        viewModel: AppRouteFactory.makeOfferDetailViewModel(
          proposalID: proposalID,
          offerID: offerID
        ),
        onBack: { self.popLast(path: path) }
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
    }
  }
}
