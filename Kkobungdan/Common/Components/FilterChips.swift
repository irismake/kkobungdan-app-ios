//
//  FilterChips.swift
//  Kkobungdan
//
//  가로 스크롤 필터 칩(선택 시 indigo). 내 활동·채팅 목록에서 공용.
//

import SwiftUI

struct FilterChips<Item: Hashable>: View {
  let items: [Item]
  @Binding var selection: Item
  let title: (Item) -> String

  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 8) {
        ForEach(items, id: \.self) { item in
          let isSelected = item == selection
          Button {
            selection = item
          } label: {
            Text(title(item))
              .textStyle(.title2, kerning: -0.1)
              .foregroundColor(isSelected ? Color.indigo000 : Color.gray800)
              .padding(.horizontal, 16)
              .padding(.vertical, 6)
              .background(isSelected ? Color.indigo500 : Color.gray200)
              .clipShape(Capsule())
          }
          .buttonStyle(.plain)
        }
      }
      .padding(.horizontal, 16)
    }
  }
}

#Preview {
  @Previewable @State var selection = "전체"
  FilterChips(items: ["전체", "안 읽음", "진행중"], selection: $selection) { $0 }
    .padding(.vertical, 16)
}
