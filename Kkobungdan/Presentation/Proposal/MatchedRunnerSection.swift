//
//  MatchedRunnerSection.swift
//  Kkobungdan
//
//  Created by 김가희 on 5/10/26.
//

import SwiftUI

/// 매칭이 완료된 proposal 의 의뢰자(orderer) 화면에 노출되는 매칭 러너 카드.
struct MatchedRunnerSection: View {
  let nickname: String
  let level: Int
  let appliedAt: String

  var body: some View {
    VStack(alignment: .leading, spacing: 24) {
      UserInfoHeader(name: nickname, level: level)

      Text(appliedAt)
        .textStyle(.caption5)
        .foregroundColor(Color.gray600)
        .padding(.horizontal, 2)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal, 16)
    .padding(.top, 16)
    .padding(.bottom, 20)
    .background(Color.white)
    .clipShape(RoundedRectangle(cornerRadius: 10))
    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray200, lineWidth: 1))
  }
}

#Preview {
  MatchedRunnerSection(
    nickname: "카야잼",
    level: 7,
    appliedAt: "2026. 1. 22. 오후 10:05:17 지원"
  )
  .padding(16)
  .background(Color.gray000)
}
