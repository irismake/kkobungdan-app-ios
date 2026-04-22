//
//  ProposalDetailView.swift
//  OderRun
//
//  Created by 김가희 on 3/26/26.
//

import SwiftUI

struct ProposalDetailView: View {
  let title: String
  let description: String
  let date: String
  let time: String
  let fee: String
  let nickname: String
  var level: Int = 1
  var levelGrade: String = ""
  var onBack: () -> Void = {}
  var onApply: () -> Void = {}

  var body: some View {
    VStack(spacing: 0) {
      AppBar(title: "요청 상세", onBack: onBack)

      // Content area
      VStack(spacing: 0) {
        ScrollView {
          VStack(alignment: .leading, spacing: 12) {
            ApplicantProfile
            ProposalCard(
              title: title,
              description: description,
              date: date,
              time: time,
              fee: fee
            )
          }
          .padding(.horizontal, Layout.screenHorizontalPadding)
          .padding(.vertical, 12)
        }
      }
      .frame(maxHeight: .infinity)
      .overlay(alignment: .bottom) {
        Rectangle()
          .fill(Color.gray200)
          .frame(height: 1)
      }

      // Bottom button
      VStack(spacing: 0) {
        ConfirmButton(title: "지원하기") {
          onApply()
        }
      }
      .padding(.horizontal, Layout.screenHorizontalPadding)
      .padding(.top, 16)
      .padding(.bottom, 32)
    }
    .background(Color.gray000)
  }

  private var ApplicantProfile: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(nickname)
        .font(.custom("Pretendard-SemiBold", size: 18))
        .kerning(-0.4)
        .foregroundColor(.black)

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
          .foregroundColor(Color.amber500)

        HStack(spacing: 4) {
          HStack(spacing: 1) {
            Text("Lv \(level)")
              .font(.custom("Pretendard-Medium", size: 14))
              .kerning(-0.15)
              .foregroundColor(Color.gray900)
            Text(":")
              .font(.custom("Pretendard-Medium", size: 14))
              .foregroundColor(Color.gray900)
          }
          Text(levelGrade)
            .font(.custom("Pretendard-Medium", size: 14))
            .kerning(-0.15)
            .foregroundColor(Color.gray900)
        }
        .appLineHeight(20, fontName: "Pretendard-Medium", fontSize: 14)
      }
    }
    .padding(.horizontal, 16)
  }
}

#Preview {
  ProposalDetailView(
    title: "강남역 곱창전골 웨이팅",
    description: "제가 도착하기 전에 미리 줄 서있어주실 분!\n인원은 3명입니다.",
    date: "2025년 11월 25일",
    time: "오후 3시",
    fee: "8,000원",
    nickname: "{닉네임}",
    level: 1,
    levelGrade: "{등급}"
  )
}
