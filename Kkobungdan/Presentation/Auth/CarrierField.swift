//
//  CarrierField.swift
//  Kkobungdan
//
//  Created by 김가희 on 5/30/26.
//

import SwiftUI

/// 통신사 선택 필드. 어느 단계에서든 탭하면 시트가 열려 다시 선택할 수 있다.
/// 통신사 시트는 키보드 포커스(@FocusState)가 아니라 viewModel.focus(.carrier) 로만 관리한다.
struct CarrierField: View {
  let carrier: String?
  let isActive: Bool
  let onTap: () -> Void

  var body: some View {
    LabeledFieldContainer(label: "통신사") {
      HStack(spacing: 0) {
        Text(carrier ?? "통신사 선택")
          .textStyle(.inputBody1)
          .foregroundColor(carrier == nil ? .gray500 : .gray900)

        Spacer(minLength: 0)

        Image("icon_arrow_down")
          .renderingMode(.template)
          .resizable()
          .scaledToFit()
          .frame(width: 24, height: 24)
          .foregroundColor(Color.gray600)
      }
      .textFieldBox(isActive: isActive)
      .contentShape(Rectangle())
      .onTapGesture(perform: onTap)
    }
  }
}
