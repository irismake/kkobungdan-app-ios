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
        onApply: {
          path.wrappedValue.append(.accountRegister(proposalID: proposalID))
        },
        onMine: {
          // 홈에서 탭한 요청이 내 요청이면 내 요청 상세로 라우트를 교체한다.
          if !path.wrappedValue.isEmpty {
            path.wrappedValue[path.wrappedValue.count - 1] = .myProposalDetail(proposalID: proposalID)
          }
        }
      )
      .navigationBarBackButtonHidden(true)
    case let .accountRegister(proposalID):
      AccountRegisterView(
        viewModel: AppRouteFactory.makeAccountRegisterViewModel(proposalID: proposalID),
        onBack: { self.popLast(path: path) },
        onApplied: {
          path.wrappedValue.append(.applyComplete(proposalID: proposalID))
        }
      )
      .navigationBarBackButtonHidden(true)
    case .applyComplete:
      ApplyCompleteView(
        onConfirm: {
          path.wrappedValue.removeAll()
        },
        onViewHistory: {
          // home segment 에는 offer 가 보이는 곳이 없으므로 activity 탭으로 보낸다.
          // 거기서 본인 offer 카드를 탭하면 `.runnerApplyDetail(proposalID:offerID:)` 로 진입.
          path.wrappedValue.removeAll()
          self.selectedTab = .activity
        }
      )
      .navigationBarBackButtonHidden(true)
    case let .myProposalDetail(proposalID):
      MyProposalDetailView(
        viewModel: AppRouteFactory.makeMyProposalDetailViewModel(proposalID: proposalID),
        onBack: { self.popLast(path: path) },
        onShowApplicants: {
          path.wrappedValue.append(.applicantList(proposalID: proposalID))
        }
      )
      .navigationBarBackButtonHidden(true)
    case let .runnerApplyDetail(proposalID, offerID):
      ApplyDetailView(
        viewModel: AppRouteFactory.makeApplyDetailViewModel(
          proposalID: proposalID,
          offerID: offerID
        ),
        onBack: { self.popLast(path: path) }
      )
      .navigationBarBackButtonHidden(true)
    case let .applicantOfferDetail(proposalID, offerID):
      ApplyDetailView(
        viewModel: AppRouteFactory.makeApplyDetailViewModel(
          proposalID: proposalID,
          offerID: offerID
        ),
        onBack: { self.popLast(path: path) }
      )
      .navigationBarBackButtonHidden(true)
    case let .applicantList(proposalID):
      ApplicantListView(
        viewModel: AppRouteFactory.makeApplicantListViewModel(proposalID: proposalID),
        onBack: { self.popLast(path: path) },
        onAccepted: {
          path.wrappedValue = [.myProposalDetail(proposalID: proposalID)]
        },
        onSelectApplicant: { proposalID, offerID in
          path.wrappedValue.append(.applicantOfferDetail(proposalID: proposalID, offerID: offerID))
        }
      )
      .navigationBarBackButtonHidden(true)
    case .addProposalDraft, .addProposalDateTime, .addProposalFee:
      addProposalDestination(for: route, path: path)
    }
  }
}
