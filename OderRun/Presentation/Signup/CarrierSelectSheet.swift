//
//  CarrierSelectSheet.swift
//  OderRun
//
//  Created by 김가희 on 5/30/26.
//

import SwiftUI

/// 통신사 선택 바텀시트.
struct CarrierSelectSheet: View {
  let carriers: [String]
  let onClose: () -> Void
  let onSelect: (String) -> Void

  @State private var isShown = false

  var body: some View {
    ZStack(alignment: .bottom) {
      Color.black.opacity(isShown ? 0.5 : 0)
        .ignoresSafeArea()
        .onTapGesture { close(onClose) }

      if isShown {
        sheet
          .transition(.move(edge: .bottom))
      }
    }
    .onAppear {
      withAnimation(.easeOut(duration: 0.25)) { isShown = true }
    }
  }

  private var sheet: some View {
    VStack(spacing: 0) {
      Capsule()
        .fill(Color.gray400)
        .frame(width: 40, height: 4)
        .padding(.top, 8)
        .padding(.bottom, 16)

      VStack(alignment: .leading, spacing: 12) {
        Text("통신사를 선택해 주세요")
          .textStyle(.heading4)
          .foregroundColor(.gray900)

        ForEach(carriers, id: \.self) { carrier in
          Button { close { onSelect(carrier) } } label: {
            Text(carrier)
              .textStyle(.inputBody3)
              .foregroundColor(.gray700)
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(.vertical, 4)
          }
          .buttonStyle(.plain)
        }
      }
      .padding(.horizontal, 24)
      .padding(.vertical, 8)
    }
    .frame(maxWidth: .infinity)
    .padding(.bottom, 32)
    .background(
      UnevenRoundedRectangle(topLeadingRadius: 12, topTrailingRadius: 12)
        .fill(Color.white)
        .ignoresSafeArea(edges: .bottom)
    )
  }

  private func close(_ completion: @escaping () -> Void) {
    withAnimation(.easeIn(duration: 0.2)) {
      isShown = false
    } completion: {
      completion()
    }
  }
}

#Preview {
  ZStack {
    Color.gray000.ignoresSafeArea()
    CarrierSelectSheet(
      carriers: ["SKT", "KT", "LG U+", "SKT 알뜰폰", "KT 알뜰폰", "LG U+ 알뜰폰"],
      onClose: {},
      onSelect: { _ in }
    )
  }
}
