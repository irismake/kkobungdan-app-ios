//
//  AccountInfoCard.swift
//  Kkobungdan
//
//  Created by 김가희 on 3/27/26.
//

import SwiftUI

struct AccountInfoCard: View {
  let bankName: String
  let accountNumber: String
  var onCopy: () -> Void = {}

  var body: some View {
    VStack(alignment: .leading, spacing: 15.5) {
      Text("계좌번호 안내")
        .textStyle(.body2)
        .foregroundColor(Color.gray800)

      VStack(spacing: 10) {
        accountRow
        warningBox
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private var accountRow: some View {
    HStack(spacing: 0) {
      VStack(alignment: .leading, spacing: 2) {
        Text(bankName)
          .textStyle(.inputBody2)
          .foregroundColor(Color.gray800)
              
        Text(accountNumber)
          .textStyle(.inputBody3)
          .foregroundColor(Color.gray900)
      }
          
      Spacer()
          
      Button(action: onCopy) {
        Image("icon_copy")
          .renderingMode(.template)
          .resizable()
          .scaledToFit()
          .frame(width: 20, height: 20)
          .foregroundColor(Color.gray800)
      }
      .padding(10)
      .background(Color.gray100)
      .clipShape(RoundedRectangle(cornerRadius: 4))
      .overlay(
        RoundedRectangle(cornerRadius: 4)
          .stroke(Color.gray200, lineWidth: 1)
      )
      .padding(.horizontal, 4)
      .frame(height: 40)
    }
  }

  private var warningBox: some View {
    HStack(alignment: .top, spacing: 4) {
      Image("icon_warning")
        .resizable()
        .frame(width: 16, height: 16)
        .padding(.top, 2)

      Text("24시간 이내로 미입금 시 게시물이 업로드되지 않고 취소됩니다.")
        .textStyle(.body3)
        .foregroundColor(Color.amber900)
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 10)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color.amber000)
    .clipShape(RoundedRectangle(cornerRadius: 10))
    .overlay(
      RoundedRectangle(cornerRadius: 10)
        .stroke(Color.amber300, lineWidth: 1)
    )
  }
}

#Preview {
  AccountInfoCard(
    bankName: DepositAccount.bankName,
    accountNumber: DepositAccount.accountNumber,
    onCopy: {}
  )
  .padding(16)
}
