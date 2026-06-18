//
//  ContentTextField.swift
//  OderRun
//
//  Created by 김가희 on 3/27/26.
//

import SwiftUI

/// 박스 스타일 여러 줄 텍스트 입력 필드. 라벨은 바깥 `LabeledFieldContainer` 로 붙인다.
struct ContentTextField: View {
  let placeholder: String
  @Binding var text: String
  let maxLength: Int
  var height: CGFloat = 160
  var background: Color = .clear
  @FocusState private var isFocused: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      ZStack(alignment: .topLeading) {
        if text.isEmpty {
          Text(placeholder)
            .textStyle(.inputBody1)
            .foregroundColor(Color.gray500)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }

        TextEditor(text: $text)
          .textStyle(.inputBody1)
          .foregroundColor(Color.gray900)
          .focused($isFocused)
          .scrollContentBackground(.hidden)
          .onChange(of: text) { _, new in
            if new.count > maxLength {
              text = String(new.prefix(maxLength))
            }
          }
          .padding(.horizontal, 12)
          .padding(.vertical, 8)
          .frame(height: height)
      }
      .background(background)
      .clipShape(RoundedRectangle(cornerRadius: 8))
      .overlay(
        RoundedRectangle(cornerRadius: 8)
          .stroke(isFocused ? Color.indigo500 : Color.gray200, lineWidth: 1)
      )

      Text("\(text.count)/\(maxLength)")
        .textStyle(.caption5)
        .foregroundColor(Color.gray500)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
  }
}

#Preview {
  @Previewable @State var text = ""
  @Previewable @State var filled = "만남 장소 근처 카페에서 기다릴게요. 3명 기준입니다."

  VStack(spacing: 24) {
    ContentTextField(
      placeholder: "만남 장소를 포함한 요청 내용을 자세히 작성해주세요",
      text: $text,
      maxLength: 500
    )

    ContentTextField(
      placeholder: "만남 장소를 포함한 요청 내용을 자세히 작성해주세요",
      text: $filled,
      maxLength: 500
    )
  }
  .padding(16)
  .background(Color.gray000)
}
