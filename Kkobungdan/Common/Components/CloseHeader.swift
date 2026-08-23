//
//  CloseHeader.swift
//  Kkobungdan
//
//  Created by 김가희 on 5/30/26.
//

import SwiftUI

/// 제목 + 닫기 버튼(X)으로 구성된 상단 헤더.
struct CloseHeader: View {
  let title: String
  let onClose: () -> Void

  var body: some View {
    HStack(spacing: 8) {
      Text(title)
        .textStyle(.heading3)
        .foregroundColor(.gray900)

      Spacer(minLength: 0)

      closeButton
    }
    .padding(.leading, 16)
    .padding(.trailing, 16)
  }

  private var closeButton: some View {
    Button(action: onClose) {
      Image("icon_close")
        .resizable()
        .scaledToFit()
        .frame(width: 24, height: 24)
        .padding(8)
    }
  }
}

#Preview {
  VStack(spacing: 24) {
    CloseHeader(title: "인증번호를 입력해 주세요", onClose: {})
    CloseHeader(title: "계좌 등록", onClose: {})
  }
}
