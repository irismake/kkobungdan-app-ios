//
//  MissionAbortCompleteView.swift
//  OderRun
//
//  임무 중단 신청 접수 완료 화면.
//

import SwiftUI

struct MissionAbortCompleteView: View {
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
          Text("임무 중단 완료")
            .textStyle(.heading6)
            .foregroundColor(Color.gray900)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)

          Text("임무 중단 신청이 정상적으로 접수되었습니다.\n환불이 필요한 경우 영업일 기준 3~5일 이내 환불 처리되며\n완료 시 알림을 보내드립니다.")
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
  MissionAbortCompleteView()
}
