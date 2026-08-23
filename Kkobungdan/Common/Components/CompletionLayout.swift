//
//  CompletionLayout.swift
//  Kkobungdan
//
//  "완료 안내" 공통 레이아웃 — 원형 체크 아이콘 + 제목 + 안내 문구 + 하단 버튼 1개.
//  신고 접수 완료·임무 중단 완료가 동일 디자인이라 이 표현 컴포넌트를 공유한다.
//

import SwiftUI

struct CompletionLayout: View {
  let title: String
  let message: String
  var buttonTitle: String = "홈으로 돌아가기"
  let onPrimary: () -> Void

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
          Text(title)
            .textStyle(.heading6)
            .foregroundColor(Color.gray900)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)

          Text(message)
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

      OutlineButton(title: buttonTitle) {
        onPrimary()
      }
      .padding(.horizontal, Layout.screenHorizontalPadding)
      .padding(.top, 16)
      .padding(.bottom, 20)
    }
    .background(Color.white)
  }
}
