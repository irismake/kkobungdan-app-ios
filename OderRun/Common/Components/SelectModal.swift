//
//  SelectModal.swift
//  OderRun
//
//  Created by 김가희 on 3/27/26.
//

import SwiftUI

struct SelectModal: View {
  let title: String
  let description: String
  let infoTitle: String
  var infoItems: [String] = []
  let onCancel: () -> Void
  let onConfirm: () -> Void

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
            .textStyle(.heading2, weight: .bold)
            .foregroundColor(Color.gray900)
            .multilineTextAlignment(.center)

          Text(description)
            .textStyle(.body3)
            .foregroundColor(Color.gray600)
            .multilineTextAlignment(.center)
        }

        VStack(alignment: .leading, spacing: 8) {
          Text(infoTitle)
            .textStyle(.caption3)
            .kerning(0)
            .foregroundColor(Color.blue900)

          VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(infoItems.enumerated()), id: \.offset) { index, item in
              Text("\(index + 1). \(item)")
                .textStyle(.caption4)
                .foregroundColor(Color.blue800)
            }
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.blue000)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
          RoundedRectangle(cornerRadius: 14)
            .stroke(Color.blue200, lineWidth: 1)
        )
          
        // Buttons
        HStack(spacing: 8) {
          Button(action: onCancel) {
            Text("취소")
              .textStyle(.interHeading1)
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
              .textStyle(.interHeading1)
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
  SelectModal(
    title: "이 지원자를 선택하시겠습니까?",
    description: "지원자 선택 시 카카오톡 채팅방이 자동 개설되며,\n입장 코드는 알림을 통해 안내됩니다.",
    infoTitle: "💡 카카오 채팅방 이용방법",
    infoItems: ["내용내용", "내용내욘"],
    onCancel: {},
    onConfirm: {}
  )
}
