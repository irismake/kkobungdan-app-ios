//
//  CloseHeader.swift
//  Kkobungdan
//
//  Created by 김가희 on 5/30/26.
//

import SwiftUI

/// 닫기 버튼(X) + 제목으로 구성된 상단 헤더. 회원가입·인증 등 여러 플로우에서 공용으로 사용한다.
struct CloseHeader: View {
  /// 닫기 버튼(X) 위치. `.leading` = 제목 앞(왼쪽), `.trailing` = 제목 뒤(오른쪽).
  enum ClosePosition {
    case leading, trailing
  }

  let title: String
  var closePosition: ClosePosition = .leading
  let onClose: () -> Void

  var body: some View {
    HStack(spacing: 8) {
      if closePosition == .leading {
        closeButton
      }

      Text(title)
        .textStyle(.heading3)
        .foregroundColor(.gray900)

      Spacer(minLength: 0)

      if closePosition == .trailing {
        closeButton
      }
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
    CloseHeader(title: "계좌 등록", closePosition: .trailing, onClose: {})
  }
}
