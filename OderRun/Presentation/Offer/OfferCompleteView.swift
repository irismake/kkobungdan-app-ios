//
//  OfferCompleteView.swift
//  OderRun
//
//  Created by 김가희 on 3/26/26.
//

import SwiftUI

struct OfferCompleteView: View {
  var onConfirm: () -> Void = {}
  var onViewHistory: () -> Void = {}

  var body: some View {
    VStack(spacing: 0) {
      // Content area
      VStack(spacing: 24) {
        Spacer()
          .frame(height: 160)

        // Icon
        ZStack {
          Circle()
            .fill(Color.emerald000)
            .frame(width: 80, height: 80)

          Image("icon_check")
            .renderingMode(.template)
            .resizable()
            .frame(width: 48, height: 48)
            .foregroundColor(Color.emerald500)
        }

        // Text
        VStack(spacing: 8) {
          Text("지원 완료")
            .textStyle(.heading2)
            .foregroundColor(Color.gray900)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)

          Text("행님이 검토 중이에요.\n선택되면 알림으로 알려드릴게요.")
            .textStyle(.body3)
            .kerning(-0.4)
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

      // Bottom buttons
      VStack(spacing: 8) {
        FillButton(title: "확인") {
          onConfirm()
        }

        OutlineButton(title: "지원 내역 보기") {
          onViewHistory()
        }
      }
      .padding(.horizontal, Layout.screenHorizontalPadding)
      .padding(.top, 16)
      .padding(.bottom, 20)
    }
    .background(Color.gray000)
  }
}

#Preview {
  OfferCompleteView()
}
