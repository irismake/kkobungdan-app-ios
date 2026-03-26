//
//  CompleteButton.swift
//  OderRun
//
//  Created by 김가희 on 3/17/26.
//

import SwiftUI

struct CompleteButton: View {
  let title: String
  var isEnabled: Bool = true
  let action: () -> Void

  var body: some View {
    Button(action: { if isEnabled {
      action()
    } }) {
      Text(title)
        .font(.custom("Pretendard-SemiBold", size: 16))
        .kerning(-0.3)
        .lineSpacing(24)
        .foregroundColor(isEnabled ? .white : .gray400)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(isEnabled ? Color.indigo500 : Color.gray200)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    .buttonStyle(.plain)
  }
}

#Preview {
  ScreenContainer {
    VStack(spacing: 10) {
      CompleteButton(title: "동의하고 시작하기", isEnabled: true, action: {})

      CompleteButton(title: "동의하고 시작하기", isEnabled: false, action: {})
    }
  }
  .padding()
}
