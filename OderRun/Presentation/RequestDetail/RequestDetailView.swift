//
//  RequestDetailView.swift
//  OderRun
//
//  Created by 김가희 on 3/26/26.
//

import SwiftUI

struct RequestDetailView: View {
  let title: String
  let description: String
  let date: String
  let time: String
  let fee: String
  var badges: [BadgeItem] = []
  var applicantCount: Int = 0
  var onBack: () -> Void = {}

  var body: some View {
    VStack(spacing: 0) {
      AppBar(title: "내 요청 상세", onBack: onBack)

      // Content area
      VStack(spacing: 0) {
        ScrollView {
          ScreenContainer {
            RequestCard(
              title: title,
              description: description,
              date: date,
              time: time,
              fee: fee,
              badges: badges
            )
          }
          .padding(.vertical, 12)
        }

        Spacer()

        // 고객센터 안내
        Text("고객센터 email@gmail")
          .font(.custom("Pretendard-Regular", size: 14))
          .kerning(-0.1)
          .foregroundColor(Color.gray700)
          .frame(maxWidth: .infinity)
          .padding(.bottom, 32)
      }
      .frame(maxHeight: .infinity)
      .overlay(alignment: .bottom) {
        Rectangle()
          .fill(Color.gray200)
          .frame(height: 1)
      }

      // Bottom buttons
      VStack(spacing: 8) {
        CompleteButton(title: "지원 보기(\(applicantCount))") {
          // TODO: 지원 목록 화면으로 이동
        }

        CancelButton(title: "요청 취소") {
          // TODO: 요청 취소 액션
        }
      }
      .padding(.horizontal, Layout.screenHorizontalPadding)
      .padding(.top, 16)
      .padding(.bottom, 32)
    }
    .background(Color.gray000)
  }
}

#Preview {
  RequestDetailView(
    title: "강남역 곱창전골 웨이팅",
    description: "제가 도착하기 전에 미리 줄 서있어주실 분!\n인원은 3명입니다.",
    date: "2025년 11월 25일",
    time: "오후 3시",
    fee: "8,000원",
    badges: [
      BadgeItem(text: "대기중", textColor: .blue500, bgColor: .blue000),
      BadgeItem(text: "새로운 지원 도착", textColor: .amber600, bgColor: .amber000)
    ],
    applicantCount: 2
  )
}
