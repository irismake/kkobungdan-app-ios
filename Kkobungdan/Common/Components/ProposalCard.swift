//
//  ProposalCard.swift
//  Kkobungdan
//
//  Created by 김가희 on 3/26/26.
//

import SwiftUI

struct BadgeItem {
  let text: String
  var textColor: Color = .rose500
  var bgColor: Color = .rose000
  var iconName: String? = nil
}

struct ProposalCard: View {
  let title: String
  let description: String
  let date: String
  let time: String
  let fee: String
  var badges: [BadgeItem] = []

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      if !badges.isEmpty {
        badgeSection
      }

      contentSection
        .padding(.bottom, 16)
        .overlay(alignment: .bottom) {
          Rectangle()
            .fill(Color.gray200)
            .frame(height: 1)
        }

      feeSection
    }
    .padding(16)
    .background(Color.white)
    .clipShape(RoundedRectangle(cornerRadius: 10))
    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray200, lineWidth: 1))
  }

  private var badgeSection: some View {
    HStack(spacing: 4) {
      ForEach(badges.indices, id: \.self) { index in
        let badge = badges[index]
        Badge(text: badge.text, textColor: badge.textColor, bgColor: badge.bgColor, iconName: badge.iconName)
      }
    }
  }

  private var contentSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(title)
        .textStyle(.title1)
        .foregroundColor(Color.gray900)
        .frame(maxWidth: .infinity, alignment: .leading)

      Text(description)
        .textStyle(.body3)
        .foregroundColor(Color.gray700)
        .frame(maxWidth: .infinity, alignment: .leading)

      VStack(alignment: .leading, spacing: 6) {
        dateTimeRow(imageName: "icon_calendar", text: date)
        dateTimeRow(imageName: "icon_clock", text: time)
      }
    }
  }

  private func dateTimeRow(imageName: String, text: String) -> some View {
    HStack(spacing: 6) {
      Image(imageName)
        .renderingMode(.template)
        .resizable()
        .frame(width: 18, height: 18)
        .foregroundColor(Color.gray800)

      Text(text)
        .textStyle(.body2)
        .kerning(-0.15)
        .foregroundColor(Color.gray700)
    }
  }

  private var feeSection: some View {
    HStack(alignment: .center, spacing: 0) {
      Text(fee)
        .textStyle(.heading4)
        .foregroundColor(Color.indigo500)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

#Preview {
  VStack(spacing: 12) {
    ProposalCard(
      title: "강남역 곱창전골 웨이팅",
      description: "제가 도착하기 전에 미리 줄 서있어주실 분!\n인원은 3명입니다.",
      date: "2025년 11월 25일",
      time: "오후 3시",
      fee: "8,000원",
      badges: [
        BadgeItem(text: "대기중", textColor: .blue500, bgColor: .blue000),
        BadgeItem(text: "새로운 지원 도착", textColor: .amber600, bgColor: .amber000)
      ]
    )
    ProposalCard(
      title: "{타이틀}",
      description: "{내용}",
      date: "{날짜}",
      time: "{시간}",
      fee: "{금액}",
      badges: [
        BadgeItem(text: "대기중", textColor: .blue500, bgColor: .blue000)
      ]
    )
  }
  .padding(16)
  .background(Color.gray000)
}
