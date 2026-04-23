//
//  ConfirmButton.swift
//  OderRun
//
//  Created by 김가희 on 3/17/26.
//

import SwiftUI

struct ConfirmButton: View {
  let title: String
  var isEnabled: Bool = true
  let action: () -> Void

  var body: some View {
    Button(action: { if isEnabled {
      action()
    } }) {
      Text(title)
        .textStyle(.heading3)
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
      ConfirmButton(title: "동의하고 시작하기", isEnabled: true, action: {})

      ConfirmButton(title: "동의하고 시작하기", isEnabled: false, action: {})
    }
  }
  .padding()
}
