//
//  HomeView.swift
//  OderRun
//
//  Created by 김가희 on 3/26/26.
//

import SwiftUI

struct HomeProposalItem: Identifiable {
  let id: UUID = .init()
  let title: String
  let description: String
  let date: String
  let time: String
  let fee: String
}

struct HomeView: View {
  @State private var selectedTab: HomeTab = .home

  // TODO: ViewModel에서 실제 데이터로 교체
  private let proposals: [HomeProposalItem] = [
    HomeProposalItem(
      title: "강남역 곱창전골 웨이팅",
      description: "제가 도착하기 전에 미리 줄 서있어주실 분!\n인원은 3명입니다.",
      date: "2025년 11월 25일",
      time: "오후 3시",
      fee: "8,000원"
    )
  ]

  var body: some View {
    VStack(spacing: 0) {
      tabContent

      ZStack(alignment: .topTrailing) {
        BottomNavBar(selectedTab: $selectedTab)

        if selectedTab == .home {
          FloatingActionButton {
            // TODO: 의뢰 작성 화면으로 이동
          }
          .padding(.trailing, 20)
          .offset(y: -(56 + 4))
        }
      }
    }
  }

  @ViewBuilder
  private var tabContent: some View {
    switch selectedTab {
    case .home:
      ScrollView {
        VStack(spacing: 12) {
          ForEach(proposals) { proposal in
            RequestCard(
              title: proposal.title,
              description: proposal.description,
              date: proposal.date,
              time: proposal.time,
              fee: proposal.fee
            )
          }
        }
        .padding(16)
      }
      .background(Color.gray000)
    case .notifications:
      NotificationView()
    default:
      Spacer()
        .background(Color.gray000)
    }
  }
}

#Preview {
  HomeView()
}
