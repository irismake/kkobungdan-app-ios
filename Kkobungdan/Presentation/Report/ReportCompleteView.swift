//
//  ReportCompleteView.swift
//  Kkobungdan
//
//  신고 접수 완료 화면.
//

import SwiftUI

struct ReportCompleteView: View {
  var onHome: () -> Void = {}

  var body: some View {
    VStack(spacing: 0) {
      VStack(spacing: 24) {
        Spacer()

        ZStack {
          Circle()
            .fill(Color.rose000)
            .frame(width: 48, height: 48)

          Image("icon_big_circle_check")
            .renderingMode(.template)
            .resizable()
            .frame(width: 40, height: 40)
            .foregroundColor(Color.rose500)
        }

        VStack(spacing: 8) {
          Text("신고 접수 완료")
            .textStyle(.heading6)
            .foregroundColor(Color.gray900)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)

          Text("운영팀이 신고 내용을 확인하고\n필요한 조치가 진행될 예정입니다.\n함께 안전한 커뮤니티를 만들어 주셔서 감사합니다.")
            .textStyle(.body3)
            .foregroundColor(Color.gray600)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
        }

        Spacer()
      }
      .frame(maxHeight: .infinity)
      .overlay(alignment: .bottom) {
        Rectangle()
          .fill(Color.gray200)
          .frame(height: 1)
      }

      OutlineButton(title: "홈으로 돌아가기") {
        onHome()
      }
      .padding(.horizontal, Layout.screenHorizontalPadding)
      .padding(.top, 16)
      .padding(.bottom, 20)
    }
    .background(Color.white)
  }
}

#Preview {
  ReportCompleteView()
}
