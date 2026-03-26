//
//  CancelButton.swift
//  OderRun
//
//  Created by 김가희 on 3/26/26.
//

import SwiftUI

struct CancelButton: View {
  let title: String
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Text(title)
        .font(.custom("Pretendard-SemiBold", size: 16))
        .kerning(-0.2)
        .foregroundColor(Color.gray700)
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
          RoundedRectangle(cornerRadius: 12)
            .stroke(Color.gray300, lineWidth: 1)
        )
    }
    .buttonStyle(.plain)
  }
}

#Preview {
  CancelButton(title: "요청 취소") {}
    .padding()
}
