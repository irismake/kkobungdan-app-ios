//
//  RunnerCard.swift
//  OderRun
//
//  Created by 김가희 on 3/26/26.
//

import SwiftUI

struct RunnerCard: View {
  let nickname: String
  let level: Int
  let appliedAt: String
  let onSelect: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      // 상단 콘텐츠 영역
      VStack(alignment: .leading, spacing: 24) {
        OrdererInfoHeader(name: nickname, level: level)

        // 지원 일시
        Text(appliedAt)
          .textStyle(.caption5)
          .foregroundColor(Color.gray600)
          .padding(.horizontal, 2)
      }

      // 지원자 선택 버튼
      Button(action: onSelect) {
        Text("지원자 선택")
          .textStyle(.heading4)
          .foregroundColor(.white)
          .multilineTextAlignment(.center)
          .frame(maxWidth: .infinity, alignment: .center)
          .padding(.vertical, 8)
          .background(Color.indigo500)
          .clipShape(RoundedRectangle(cornerRadius: 6))
      }
      .buttonStyle(.plain)
    }
    .padding(.horizontal, 16)
    .padding(.top, 16)
    .padding(.bottom, 20)
    .background(Color.white)
    .clipShape(RoundedRectangle(cornerRadius: 10))
    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray200, lineWidth: 1))
  }
}

#Preview {
  VStack(spacing: 12) {
    RunnerCard(
      nickname: "카야잼",
      level: 7,
      appliedAt: "2026. 1. 22. 오후 10:05:17 지원",
      onSelect: {}
    )
    RunnerCard(
      nickname: "닉네임",
      level: 3,
      appliedAt: "2026. 1. 22. 오후 10:05:17 지원",
      onSelect: {}
    )
  }
  .padding(16)
  .background(Color.gray000)
}
