//
//  AppRouter+AddProposalRouting.swift
//  OderRun
//
//  '새 의뢰 작성' 3단계 플로우(제목·내용 → 날짜·시간 → 웨이팅비) push 빌더.
//  일반 탭 라우팅(`AppRouter+Routing`)과 성격이 달라 분리한다.
//

import SwiftUI

extension AppRouter {
  @ViewBuilder
  func addProposalDestination(for route: AppRoute, path: Binding<[AppRoute]>) -> some View {
    switch route {
    case .addProposalDraft:
      AddProposalView(
        onBack: { self.popLast(path: path) },
        onNext: { draft in
          path.wrappedValue.append(.addProposalDateTime(draft: draft))
        }
      )
      .navigationBarBackButtonHidden(true)
    case let .addProposalDateTime(draft):
      AddProposalDateTimeView(
        draft: draft,
        onBack: { self.popLast(path: path) },
        onNext: { updated in
          path.wrappedValue.append(.addProposalFee(draft: updated))
        }
      )
      .navigationBarBackButtonHidden(true)
    case let .addProposalFee(draft):
      AddProposalFeeView(
        draft: draft,
        viewModel: AppRouteFactory.makeAddProposalViewModel(),
        onBack: { self.popLast(path: path) },
        onCreated: { proposal in
          // 생성 후 새 의뢰 상세로 교체. 목록 갱신은 홈 복귀 시 onChange,
          // 활동 탭은 ActivityView 의 .task 가 담당한다.
          path.wrappedValue = [.myProposalDetail(proposalID: proposal.id)]
        }
      )
      .navigationBarBackButtonHidden(true)
    default:
      EmptyView()
    }
  }
}
