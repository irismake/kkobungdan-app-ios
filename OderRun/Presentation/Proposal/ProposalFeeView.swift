//
//  ProposalFeeView.swift
//  OderRun
//
//  Created by 김가희 on 3/28/26.
//

import SwiftUI

struct ProposalFeeView: View {
  @Environment(\.dismiss) private var dismiss
  @State private var fee = ""
  @FocusState private var isFocused: Bool

  private var isSubmitEnabled: Bool {
    !fee.isEmpty
  }

  var body: some View {
    VStack(spacing: 0) {
      headerSection

      ScrollView {
        VStack(alignment: .leading, spacing: 24) {
          feeField

          AccountInfoCard(
            bankName: "토스뱅크",
            accountNumber: "1234-56-24687"
          )
        }
        .padding(16)
      }

      BottomActionBar(title: "등록하기", isEnabled: isSubmitEnabled) {
        // TODO: 등록 액션
      }
    }
    .background(Color.gray000)
    .navigationBarHidden(true)
  }

  private var headerSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      AppBar(isProgress: true, onBack: {})

      VStack(alignment: .leading, spacing: 8) {
        Text("웨이팅비 입력")
          .textStyle(.heading2)
          .foregroundColor(Color.gray900)
          .padding(.horizontal, 16)

        Text("원하는 웨이팅비를 제시해 주세요")
          .textStyle(.body3)
          .foregroundColor(Color.gray600)
          .padding(.horizontal, 16)
      }
    }
    .padding(.bottom, 32)
    .overlay(alignment: .bottom) {
      Rectangle()
        .fill(Color.gray200)
        .frame(height: 1)
    }
  }

  private var feeField: some View {
    TitleTextField(
      title: "웨이팅비",
      placeholder: "금액을 작성해 주세요",
      text: $fee,
      autoFocus: true
    )
  }
}

#Preview {
  ProposalFeeView()
}
