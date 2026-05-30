//
//  CloseHeader.swift
//  OderRun
//
//  Created by 김가희 on 5/30/26.
//

import SwiftUI

/// 닫기 버튼(X) + 제목으로 구성된 상단 헤더. 회원가입·인증 등 여러 플로우에서 공용으로 사용한다.
struct CloseHeader: View {
  let title: String
  let onClose: () -> Void

  var body: some View {
    HStack(spacing: 8) {
      Button(action: onClose) {
        Image("icon_close")
          .resizable()
          .scaledToFit()
          .frame(width: 24, height: 24)
          .padding(8)
      }

      Text(title)
        .textStyle(.heading3)
        .foregroundColor(.gray900)

      Spacer(minLength: 0)
    }
    .padding(.leading, 8)
  }
}

#Preview {
  CloseHeader(title: "인증번호를 입력해 주세요", onClose: {})
}
