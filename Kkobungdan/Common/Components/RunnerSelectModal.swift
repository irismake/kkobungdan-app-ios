//
//  RunnerSelectModal.swift
//  Kkobungdan
//
//  Created by 김가희 on 3/27/26.
//

import SwiftUI

struct RunnerSelectModal: View {
  let runnerName: String
  let onCancel: () -> Void
  let onConfirm: () -> Void

  private var title: String {
    let name = runnerName.count > 6 ? "\(runnerName.prefix(6))…" : runnerName
    let particle = runnerName.hasBatchim ? "을" : "를"
    return "\(name)\(particle) 선택하시겠습니까?"
  }

  private let description: String = "꼬붕 선택 시 카카오톡 채팅방이 자동 개설되며,\n입장 코드는 알림을 통해 안내됩니다."

  var body: some View {
    ZStack {
      Color.black.opacity(0.4)
        .ignoresSafeArea()
        .onTapGesture { onCancel() }

      VStack(spacing: 16) {
        ZStack {
          Circle()
            .fill(Color.blue000)
            .frame(width: 48, height: 48)

          Image("icon_info")
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
            .foregroundColor(Color.blue500)
        }

        VStack(spacing: 4) {
          Text(title)
            .textStyle(.heading3, weight: .bold)
            .foregroundColor(Color.gray900)
            .multilineTextAlignment(.center)

          Text(description)
            .textStyle(.body3)
            .foregroundColor(Color.gray600)
            .multilineTextAlignment(.center)
        }

        HStack(spacing: 8) {
          Button(action: onCancel) {
            Text("취소")
              .textStyle(.body1)
              .foregroundColor(Color.gray700)
              .multilineTextAlignment(.center)
              .frame(maxWidth: .infinity)
              .frame(height: 50)
              .background(Color.white)
              .clipShape(RoundedRectangle(cornerRadius: 12))
              .overlay(
                RoundedRectangle(cornerRadius: 12)
                  .stroke(Color.gray300, lineWidth: 1)
              )
          }
          .buttonStyle(.plain)

          Button(action: onConfirm) {
            Text("확인")
              .textStyle(.body1)
              .foregroundColor(.white)
              .multilineTextAlignment(.center)
              .frame(maxWidth: .infinity)
              .frame(height: 50)
              .background(Color.indigo500)
              .clipShape(RoundedRectangle(cornerRadius: 12))
          }
          .buttonStyle(.plain)
        }
      }
      .padding(.top, 24)
      .padding(.bottom, 16)
      .padding(.horizontal, 16)
      .background(Color.white)
      .clipShape(RoundedRectangle(cornerRadius: 16))
      .padding(.horizontal, 24)
    }
  }
}

#Preview {
  RunnerSelectModal(
    runnerName: "꼬붕이",
    onCancel: {},
    onConfirm: {}
  )
}
