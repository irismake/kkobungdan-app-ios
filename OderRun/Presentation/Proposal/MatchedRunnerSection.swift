//
//  MatchedRunnerSection.swift
//  OderRun
//
//  Created by 김가희 on 5/10/26.
//

import SwiftUI

/// 매칭이 완료된 proposal 의 의뢰자(orderer) 화면에 노출되는 매칭 러너 카드.
struct MatchedRunnerSection: View {
  let nickname: String
  let level: Int
  let grade: String
  let appliedAt: String

  var body: some View {
    VStack(alignment: .leading, spacing: 24) {
      VStack(alignment: .leading, spacing: 4) {
        Text(nickname)
          .textStyle(.title1)
          .foregroundColor(.black)
          .frame(width: 163, alignment: .topLeading)

        VStack(alignment: .leading, spacing: 0) {
          Text("웨이팅 레벨")
            .textStyle(.caption2)
            .foregroundColor(Color.gray500)

          HStack(spacing: 6) {
            Image("icon_users")
              .renderingMode(.template)
              .resizable()
              .frame(width: 16, height: 16)
              .padding(.vertical, 2)
              .foregroundColor(Color.amber500)

            HStack(spacing: 4) {
              HStack(spacing: 1) {
                Text("Lv \(level)")
                Text(":")
              }
              Text(grade)
            }
            .textStyle(.body2)
            .kerning(-0.15)
            .foregroundColor(Color.gray900)
          }
        }
        .padding(.horizontal, 1)
      }

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
    level: 40,
    grade: "고수",
    appliedAt: "2026. 1. 22. 오후 10:05:17 지원"
  )
  .padding(16)
  .background(Color.gray000)
}
