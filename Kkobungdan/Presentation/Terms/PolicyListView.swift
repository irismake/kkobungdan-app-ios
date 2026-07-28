//
//  PolicyListView.swift
//  Kkobungdan
//
//  프로필 > 약관 및 정책. 각 항목을 누르면 외부 브라우저로 정책 문서를 연다.
//

import SwiftUI

struct PolicyListView: View {
  var onBack: () -> Void

  @Environment(\.openURL) private var openURL

  var body: some View {
    VStack(spacing: 0) {
      AppBar(title: "약관 및 정책", onBack: onBack)

      VStack(spacing: 0) {
        Rectangle().fill(Color.gray200).frame(height: 1)

        policyRow(icon: "doc.text", title: "이용약관", url: PolicyURL.termsOfService)
        policyRow(icon: "lock.shield", title: "개인정보 처리방침", url: PolicyURL.privacyPolicy)
        policyRow(icon: "list.bullet.rectangle", title: "운영정책", url: PolicyURL.operationPolicy)
      }
      .padding(.top, 16)

      Spacer()
    }
    .background(Color.gray000)
    .navigationBarHidden(true)
  }

  private func policyRow(icon: String, title: String, url: URL) -> some View {
    Button {
      openURL(url)
    } label: {
      HStack(spacing: 12) {
        HStack(spacing: 8) {
          Image(systemName: icon)
            .resizable()
            .scaledToFit()
            .frame(width: 20, height: 20)
            .foregroundColor(Color.gray900)

          Text(title)
            .textStyle(.title3)
            .foregroundColor(Color.gray900)

          Spacer()
        }

        Image("icon_arrow_right")
          .renderingMode(.template)
          .resizable()
          .scaledToFit()
          .frame(width: 20, height: 20)
          .foregroundColor(Color.gray400)
      }
      .padding(.horizontal, 24)
      .padding(.vertical, 20)
      .background(Color.white)
      .overlay(alignment: .bottom) {
        Rectangle().fill(Color.gray200).frame(height: 1)
      }
    }
    .buttonStyle(.plain)
  }
}

#Preview {
  PolicyListView(onBack: {})
}
