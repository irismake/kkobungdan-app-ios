//
//  OrdererInfoHeader.swift
//  OderRun
//
//  Created by 김가희 on 6/17/26.
//
//  요청 상세·지원 상세 상단의 요청자(orderer) 이름 + 웨이팅 레벨 헤더.
//

import SwiftUI

struct OrdererInfoHeader: View {
  let name: String
  let level: Int
  var spacing: CGFloat = 4

  var body: some View {
    VStack(alignment: .leading, spacing: spacing) {
      Text(name)
        .textStyle(.title1)
        .foregroundColor(.black)

      WaitingLevelLabel(level: level)
        .padding(.leading, 1)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

#Preview {
  OrdererInfoHeader(name: "{닉네임}", level: 5)
    .padding(16)
    .background(Color.gray000)
}
