//
//  BottomNavBar.swift
//  OderRun
//
//  Created by 김가희 on 3/26/26.
//

import SwiftUI

enum HomeTab {
  case home, activity, notifications, profile
}

struct BottomNavBar: View {
  @Binding var selectedTab: HomeTab

  var body: some View {
    VStack(spacing: 0) {
      Rectangle()
        .fill(Color.gray200)
        .frame(height: 1)

      HStack(spacing: 16) {
        tabItem(tab: .home, imageName: "tab_home", label: "홈")
        tabItem(tab: .activity, imageName: "tab_activity", label: "내 활동")
        tabItem(tab: .notifications, imageName: "tab_notification", label: "알림")
        tabItem(tab: .profile, imageName: "tab_profile", label: "프로필")
      }
      .padding(.top, 16)
      .padding(.bottom, 32)
      .padding(.horizontal, 16)
    }
    .background(Color.white)
  }

  private func tabItem(tab: HomeTab, imageName: String, label: String) -> some View {
    let isSelected = selectedTab == tab
    let color = isSelected ? Color.indigo500 : Color.gray500

    return Button {
      selectedTab = tab
    } label: {
      VStack(spacing: 4) {
        Image(imageName)
          .renderingMode(.template)
          .resizable()
          .scaledToFit()
          .frame(width: 24, height: 24)
          .foregroundColor(color)

        Text(label)
          .font(.custom("Pretendard-Medium", size: 12))
          .lineSpacing(16)
          .foregroundColor(color)
      }
      .frame(maxWidth: .infinity)
    }
    .buttonStyle(.plain)
  }
}

#Preview {
  VStack {
    Spacer()
    BottomNavBar(selectedTab: .constant(.home))
  }
}
