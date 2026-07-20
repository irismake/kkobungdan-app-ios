//
//  BankSelectSheet.swift
//  Kkobungdan
//
//  Created by 김가희 on 5/30/26.
//

import SwiftUI

/// 은행 선택 바텀시트. 3열 그리드로 은행을 나열하고 탭하면 선택 후 닫힌다.
struct BankSelectSheet: View {
  let banks: [String]
  let onClose: () -> Void
  let onSelect: (String) -> Void

  @State private var isShown = false
  @State private var dragOffset: CGFloat = 0

  private let columnCount = 3

  private var bankRows: [[String]] {
    stride(from: 0, to: banks.count, by: columnCount).map {
      Array(banks[$0 ..< min($0 + columnCount, banks.count)])
    }
  }

  var body: some View {
    ZStack(alignment: .bottom) {
      Color.black.opacity(isShown ? 0.5 : 0)
        .ignoresSafeArea()
        .onTapGesture { close(onClose) }

      if isShown {
        sheet
          .offset(y: max(0, dragOffset))
          .gesture(
            DragGesture()
              .onChanged { dragOffset = $0.translation.height }
              .onEnded { value in
                if value.translation.height > 80 {
                  close(onClose)
                } else {
                  withAnimation(.easeOut(duration: 0.2)) { dragOffset = 0 }
                }
              }
          )
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
        Text("은행을 선택해 주세요")
          .textStyle(.heading4)
          .foregroundColor(.gray900)

        VStack(spacing: 10) {
          ForEach(bankRows.indices, id: \.self) { rowIndex in
            HStack(spacing: 10) {
              ForEach(bankRows[rowIndex], id: \.self) { bank in
                Button { close { onSelect(bank) } } label: {
                  bankChip(bank)
                }
                .buttonStyle(.plain)
              }
              if bankRows[rowIndex].count < columnCount {
                ForEach(0 ..< (columnCount - bankRows[rowIndex].count), id: \.self) { _ in
                  Color.clear.frame(maxWidth: .infinity)
                }
              }
            }
          }
        }
      }
      .padding(.horizontal, 24)
      .padding(.top, 8)
    }
    .frame(maxWidth: .infinity)
    .padding(.bottom, 32)
    .background(
      UnevenRoundedRectangle(topLeadingRadius: 12, topTrailingRadius: 12)
        .fill(Color.white)
        .ignoresSafeArea(edges: .bottom)
    )
  }

  private func bankChip(_ bank: String) -> some View {
    VStack(spacing: 4) {
      // TODO: 은행 로고 이미지 확정 전까지 임시 제거 — 이미지 에셋 반영 시 복원
      // RoundedRectangle(cornerRadius: 2)
      //   .fill(Color.gray300)
      //   .frame(width: 24, height: 24)

      Text(bank)
        .textStyle(.inputBody3)
        .foregroundColor(.gray900)
        .lineLimit(1)
    }
    .frame(maxWidth: .infinity)
    .padding(.horizontal, 8)
    .padding(.vertical, 12)
    .background(Color.gray000)
    .clipShape(RoundedRectangle(cornerRadius: 8))
  }

  private func close(_ completion: @escaping () -> Void) {
    withAnimation(.easeIn(duration: 0.2)) {
      isShown = false
      dragOffset = 0
    } completion: {
      completion()
    }
  }
}

#Preview {
  ZStack {
    Color.gray000.ignoresSafeArea()
    BankSelectSheet(
      banks: [
        "NH 농협", "카카오뱅크", "KB 국민",
        "토스뱅크", "신한", "우리",
        "IBK기업", "하나", "새마을"
      ],
      onClose: {},
      onSelect: { _ in }
    )
  }
}
