//
//  SignupView.swift
//  OderRun
//
//  Created by 김가희 on 5/30/26.
//

import SwiftUI

/// 회원가입 본인인증 플로우 호스트. 각 step은 별도 파일이지만 같은 화면에서 교체된다.
struct SignupView: View {
  let onClose: () -> Void

  private enum Step {
    case phoneNumber
    case carrier
    case name
  }

  @State private var step: Step = .phoneNumber
  @State private var phoneNumber: String = ""
  @State private var carrier: String?
  @State private var name: String = ""

  var body: some View {
    ZStack {
      switch step {
      case .phoneNumber:
        PhoneNumberInputView(
          phoneNumber: $phoneNumber,
          onClose: onClose,
          onNext: { withAnimation(.easeInOut) { step = .carrier } }
        )
        .transition(.opacity)

      case .carrier:
        CarrierSelectionView(
          phoneNumber: phoneNumber,
          carrier: $carrier,
          onClose: onClose,
          onNext: { withAnimation(.easeInOut) { step = .name } }
        )
        .transition(.opacity)

      case .name:
        NameInputView(
          name: $name,
          carrier: carrier ?? "",
          phoneNumber: phoneNumber,
          onClose: onClose,
          // TODO: 다음 단계(주민번호/인증 등)로 이동
          onNext: {}
        )
        .transition(.opacity)
      }
    }
    .navigationBarBackButtonHidden(true)
    .toolbar(.hidden, for: .navigationBar)
  }
}

#Preview {
  SignupView(onClose: {})
}
