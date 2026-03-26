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
            .font(
              Font.custom("Pretendard", size: 18)
                .weight(.semibold)
            )
            .foregroundColor(.black)
            .frame(width: 163, alignment: .topLeading)

          // 웨이팅 레벨 컨테이너
          VStack(alignment: .leading, spacing: 0) {
            Text("웨이팅 레벨")
              .font(
                Font.custom("Pretendard", size: 12)
                  .weight(.regular)
              )
              .kerning(-0.15)
              .lineSpacing(8)
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
              .font(
                Font.custom("Pretendard", size: 14)
                  .weight(.medium)
              )
              .kerning(-0.15)
              // 14px font with 20px line-height => 6px extra leading
              .lineSpacing(6)
              .foregroundColor(Color.gray900)
            }
          }
          .padding(.horizontal, 1)
        }

        // 지원 일시
        Text(appliedAt)
          .font(
            Font.custom("Pretendard", size: 12)
              .weight(.regular)
          )
          // 12px font with 16px line-height => 4px extra leading
          .lineSpacing(4)
          .foregroundColor(Color.gray600)
          .padding(.horizontal, 2)
      }

      // 지원자 선택 버튼
      Button(action: onSelect) {
        Text("지원자 선택")
          .font(
            Font.custom("Pretendard", size: 16)
              .weight(.semibold)
          )
          .kerning(-0.2)
          // 16px font with 24px line-height => 8px extra leading
          .lineSpacing(8)
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
