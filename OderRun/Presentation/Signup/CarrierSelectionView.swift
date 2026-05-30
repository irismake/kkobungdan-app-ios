//
//  CarrierSelectionView.swift
//  OderRun
//
//  Created by 김가희 on 5/30/26.
//

import SwiftUI

/// 회원가입 본인인증 플로우 2단계 — 통신사 선택.
struct CarrierSelectionView: View {
  let phoneNumber: String
  @Binding var carrier: String?
  let onClose: () -> Void

  @State private var isSheetPresented = false

  private let carriers = ["SKT", "KT", "LG U+", "SKT 알뜰폰", "KT 알뜰폰", "LG U+ 알뜰폰"]

  var body: some View {
    ZStack {
      VStack(spacing: 32) {
        header

        carrierField

        phoneField

        Spacer()
      }
      .padding(.top, 8)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color.white)

      if isSheetPresented {
        CarrierSelectSheet(
          carriers: carriers,
          onClose: { isSheetPresented = false },
          onSelect: { selected in
            carrier = selected
            isSheetPresented = false
          }
        )
      }
    }
    .onAppear { isSheetPresented = true }
  }

  private var header: some View {
    HStack(spacing: 8) {
      Button(action: onClose) {
        Image("icon_close")
          .resizable()
          .scaledToFit()
          .frame(width: 24, height: 24)
          .padding(8)
      }

      Text("통신사를 선택해 주세요")
        .textStyle(.heading3)
        .foregroundColor(.gray900)

      Spacer(minLength: 0)
    }
    .padding(.leading, 8)
  }

  private var carrierField: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("통신사")
        .textStyle(.body2)
        .foregroundColor(.gray800)

      Button { isSheetPresented = true } label: {
        HStack(spacing: 0) {
          Text(carrier ?? "통신사 선택")
            .textStyle(.inputBody1)
            .foregroundColor(carrier == nil ? .gray500 : .gray900)

          Spacer(minLength: 0)

          Image("icon_arrow_down")
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
            .foregroundColor(Color.gray600)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(isSheetPresented || carrier != nil ? Color.indigo500 : Color.gray200, lineWidth: 1)
        )
      }
      .buttonStyle(.plain)
    }
    .padding(.horizontal, 16)
  }

  private var phoneField: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("휴대폰 번호")
        .textStyle(.body2)
        .foregroundColor(.gray800)

      HStack(spacing: 0) {
        Text(phoneNumber)
          .textStyle(.inputBody1)
          .foregroundColor(.gray900)

        Spacer(minLength: 0)
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .background(Color.white)
      .clipShape(RoundedRectangle(cornerRadius: 8))
      .overlay(
        RoundedRectangle(cornerRadius: 8)
          .stroke(Color.gray200, lineWidth: 1)
      )
    }
    .padding(.horizontal, 16)
  }
}

#Preview {
  CarrierSelectionView(
    phoneNumber: "010-2323-4545",
    carrier: .constant(nil),
    onClose: {}
  )
}
