//
//  TitleTextField.swift
//  OderRun
//
//  Created by 김가희 on 3/27/26.
//

import SwiftUI

struct TitleTextField: View {
  let title: String
  let placeholder: String
  @Binding var text: String
  var maxLength: Int?
  var autoFocus: Bool = false

  @FocusState private var isFocused: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title)
        .textStyle(.body2)
        .foregroundColor(Color.gray800)

      TextField(placeholder, text: $text)
        .font(.custom("Pretendard-Regular", size: 16))
        .kerning(-0.2)
        .foregroundColor(Color.gray900)
        .focused($isFocused)
        .onChange(of: text) { _, new in
          if let maxLength, new.count > maxLength {
            text = String(new.prefix(maxLength))
          }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(isFocused ? Color.indigo500 : Color.gray200, lineWidth: 1)
        )

      if let maxLength {
        HStack {
          Spacer()
          Text("\(text.count)/\(maxLength)")
            .textStyle(.caption4)
            .foregroundColor(Color.gray500)
        }
      }
    }
    .onAppear {
      if autoFocus {
        isFocused = true
      }
    }
  }
}

#Preview {
  @Previewable @State var text = ""
  @Previewable @State var filled = "성수동 OO 베이커리 소금빵 웨이팅"

  VStack(spacing: 24) {
    TitleTextField(
      title: "제목",
      placeholder: "예: 성수동 OO 베이커리 소금빵 웨이팅",
      text: $text,
      maxLength: 50
    )

    TitleTextField(
      title: "제목 (입력됨)",
      placeholder: "예: 성수동 OO 베이커리 소금빵 웨이팅",
      text: $filled,
      maxLength: 50
    )
  }
  .padding(16)
  .background(Color.gray000)
}
