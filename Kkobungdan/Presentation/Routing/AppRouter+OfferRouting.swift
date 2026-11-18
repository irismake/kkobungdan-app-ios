//
//  AppRouter+OfferRouting.swift
//  Kkobungdan
//
//  지원(offer) 관련 push 빌더 — 지원 플로우(계좌 → 첫 인사 → 완료), 지원 상세, 지원자 목록·상세.
//  `AppRouter+Routing` 의 destination 함수가 길어져(SwiftLint function_body_length) 분리한다.
//

import SwiftUI

extension AppRouter {
  @ViewBuilder
  func offerDestination(for route: AppRoute, path: Binding<[AppRoute]>) -> some View {
    switch route {
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
    case let .offerDetail(proposalID, offerID):
      OfferDetailView(
        viewModel: AppRouteFactory.makeOfferDetailViewModel(
          proposalID: proposalID,
          offerID: offerID
        ),
        onBack: { self.popLast(path: path) },
        onAbort: {
          path.wrappedValue.append(.missionAbort(target: .offer(offerID: offerID)))
        },
        onOpenChat: { room in
          path.wrappedValue.append(.chatRoom(roomID: room.id))
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
        },
        onOpenChat: { offer in
          // 대화방은 지원 1건당 1개 — 대화방 ID 는 지원 ID 와 같다.
          path.wrappedValue.append(.chatRoom(roomID: offer.id))
        }
      )
      .navigationBarBackButtonHidden(true)
    default:
      EmptyView()
    }
  }
}
