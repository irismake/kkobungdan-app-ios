//
//  ApplicantListView.swift
//  OderRun
//
//  Created by 김가희 on 3/26/26.
//

import SwiftUI

struct ApplicantItem: Identifiable {
  let id: UUID = .init()
  let nickname: String
  let level: Int
  let grade: String
  let appliedAt: String
}

struct ApplicantListView: View {
  let requestTitle: String
  let applicants: [ApplicantItem]
  var onBack: () -> Void = {}

  var body: some View {
    VStack(spacing: 0) {
      AppBar(title: "지원 리스트", onBack: onBack)

      ScrollView {
        VStack(alignment: .leading, spacing: 12) {
          // 헤더: 요청 제목 + 지원자 수
          VStack(alignment: .leading, spacing: 4) {
            Text(requestTitle)
              .font(.custom("Pretendard-Medium", size: 14))
              .kerning(-0.15)
              .appLineHeight(20, fontName: "Pretendard-Medium", fontSize: 14)
              .foregroundColor(Color.gray600)

            HStack(spacing: 0) {
              Text("\(applicants.count)명")
                .font(.custom("Pretendard-Bold", size: 18))
                .kerning(-0.4)
                .appLineHeight(28, fontName: "Pretendard-Bold", fontSize: 18)
                .foregroundColor(Color.indigo500)

              Text("이 웨이팅을 지원했습니다")
                .font(
                  Font.custom("Pretendard", size: 18)
                    .weight(.semibold)
                )
                .kerning(-0.4)
                .appLineHeight(28, fontName: "Pretendard-SemiBold", fontSize: 18)
                .foregroundColor(Color.gray700)
            }
          }

          // 지원자 카드 리스트
          ForEach(applicants) { applicant in
            ApplicantCard(
              nickname: applicant.nickname,
              level: applicant.level,
              grade: applicant.grade,
              appliedAt: applicant.appliedAt,
              onSelect: {
                // TODO: 지원자 선택 액션
              }
            )
          }
        }
        .padding(.horizontal, Layout.screenHorizontalPadding)
        .padding(.vertical, 12)
      }
    }
    .background(Color.gray000)
  }
}

#Preview {
  ApplicantListView(
    requestTitle: "강남역 곱창전골 웨이팅",
    applicants: [
      ApplicantItem(nickname: "카야잼", level: 40, grade: "고수", appliedAt: "2026. 1. 22. 오후 10:05:17 지원"),
      ApplicantItem(nickname: "닉네임", level: 10, grade: "초보", appliedAt: "2026. 1. 22. 오후 10:05:17 지원")
    ]
  )
}
