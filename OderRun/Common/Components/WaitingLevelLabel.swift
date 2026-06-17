//
//  WaitingLevelLabel.swift
//  OderRun
//
//  Created by 김가희 on 6/17/26.
//
//  "웨이팅 레벨" 표시 라벨. 프로필·지원자 카드·매칭 러너·요청 상세 등에서 공유한다.
//

import SwiftUI

struct WaitingLevelLabel: View {
  let level: Int

  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      HStack(spacing: 6) {
        Image("icon_users")
          .renderingMode(.template)
          .resizable()
          .scaledToFit()
          .frame(width: 16, height: 16)
          .foregroundColor(Color.amber500)

        Text("임무 수행 \(level)회")
          .textStyle(.body2)
          .kerning(-0.15)
          .foregroundColor(Color.gray900)
      }
    }
  }
}

#Preview {
  VStack(alignment: .leading, spacing: 16) {
    WaitingLevelLabel(level: 5)
    WaitingLevelLabel(level: 3)
  }
  .padding(16)
  .background(Color.gray000)
}
