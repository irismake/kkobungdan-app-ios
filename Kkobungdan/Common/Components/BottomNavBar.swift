//
//  BottomNavBar.swift
//  Kkobungdan
//
//  Created by 김가희 on 3/26/26.
//

import SwiftUI

enum HomeTab {
  case home, activity, notifications, profile
}

struct BottomNavBar: View {
  @Binding var selectedTab: HomeTab
  /// 알림 탭에 표시할 안읽음 개수. 0 이면 뱃지를 숨긴다.
  var unreadCount: Int = 0

  var body: some View {
    VStack(spacing: 0) {
      Rectangle()
        .fill(Color.gray200)
        .frame(height: 1)

      HStack(spacing: 16) {
        tabItem(tab: .home, imageName: "tab_home", label: "홈")
        tabItem(tab: .activity, imageName: "tab_activity", label: "내 활동")
        tabItem(tab: .notifications, imageName: "tab_notification", label: "알림", badgeCount: unreadCount)
        tabItem(tab: .profile, imageName: "tab_profile", label: "프로필")
      }
      .padding(.top, 16)
      .padding(.bottom, 20)
      .padding(.horizontal, 16)
      .frame(height: 80)
    }
    .background(Color.white)
  }

  private func tabItem(tab: HomeTab, imageName: String, label: String, badgeCount: Int = 0) -> some View {
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
          .overlay {
            if badgeCount > 0 {
              badge(count: badgeCount)
                .offset(x: 8, y: -8)
            }
          }

        Text(label)
          .textStyle(.caption3)
          .foregroundColor(color)
          .multilineTextAlignment(.center)
      }
      .frame(maxWidth: .infinity)
    }
    .buttonStyle(.plain)
  }

  private func badge(count: Int) -> some View {
    Text(count > 9 ? "9+" : "\(count)")
      .textStyle(.badge1)
      .foregroundColor(Color.indigo000)
      .frame(width: 16, height: 16)
      .background(Circle().fill(Color.indigo500))
  }
}

#Preview {
  VStack {
    Spacer()
    BottomNavBar(selectedTab: .constant(.home), unreadCount: 3)
  }
}
