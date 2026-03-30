//
//  ApplicantCard.swift
//  OderRun
//
//  Created by 김가희 on 3/26/26.
//

import SwiftUI

struct ApplicantCard: View {
  let nickname: String
  let level: Int
  let grade: String
  let appliedAt: String
  let onSelect: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      // 상단 콘텐츠 영역
      VStack(alignment: .leading, spacing: 24) {
        // 닉네임 + 레벨 정보
        VStack(alignment: .leading, spacing: 4) {
          Text(nickname)
            .font(.custom("Pretendard-SemiBold", size: 18))
            .kerning(-0.4)
            .appLineHeight(18, fontName: "Pretendard-SemiBold", fontSize: 18)
            .foregroundColor(.black)
            .frame(width: 163, alignment: .topLeading)

          // 웨이팅 레벨 컨테이너
          VStack(alignment: .leading, spacing: 0) {
            Text("웨이팅 레벨")
              .font(.custom("Pretendard-Regular", size: 12))
              .kerning(-0.15)
              .appLineHeight(20, fontName: "Pretendard-Regular", fontSize: 12)
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
              .font(.custom("Pretendard-Medium", size: 14))
              .kerning(-0.15)
              .appLineHeight(20, fontName: "Pretendard-Medium", fontSize: 14)
              .foregroundColor(Color.gray900)
            }
          }
          .padding(.horizontal, 1)
        }

        // 지원 일시
        Text(appliedAt)
          .font(.custom("Pretendard-Regular", size: 12))
          .appLineHeight(16, fontName: "Pretendard-Regular", fontSize: 12)
          .foregroundColor(Color.gray600)
          .padding(.horizontal, 2)
      }

      // 지원자 선택 버튼
      Button(action: onSelect) {
        Text("지원자 선택")
          .font(.custom("Pretendard-SemiBold", size: 16))
          .kerning(-0.2)
          .appLineHeight(24, fontName: "Pretendard-SemiBold", fontSize: 16)
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
    ApplicantCard(
      nickname: "카야잼",
      level: 40,
      grade: "고수",
      appliedAt: "2026. 1. 22. 오후 10:05:17 지원",
      onSelect: {}
    )
    ApplicantCard(
      nickname: "닉네임",
      level: 10,
      grade: "초보",
      appliedAt: "2026. 1. 22. 오후 10:05:17 지원",
      onSelect: {}
    )
  }
  .padding(16)
  .background(Color.gray000)
}
