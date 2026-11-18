//
//  ChatCard.swift
//  Kkobungdan
//
//  상세 화면 하단의 "관련 대화" 섹션. 대화 상대별 한 줄(이름·상태·대화 보기)을 나열한다.
//

import SwiftUI

/// 관련 대화 한 줄. 상태 문구는 요청 카드 배지와 같은 값을 넘긴다.
struct ChatCardItem: Identifiable {
  let id: String
  let name: String
  let statusText: String
  let onOpenChat: () -> Void
}

struct ChatCard: View {
  let items: [ChatCardItem]

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("관련 대화 · \(items.count)")
        .textStyle(.heading4)
        .kerning(0)
        .foregroundColor(.gray900)

      VStack(spacing: 0) {
        ForEach(items) { item in
          row(item)
        }
      }
    }
    .padding(16)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color.white)
    .clipShape(RoundedRectangle(cornerRadius: 10))
    .overlay(
      RoundedRectangle(cornerRadius: 10)
        .stroke(Color.gray200, lineWidth: 1)
    )
  }

  private func row(_ item: ChatCardItem) -> some View {
    Button(action: item.onOpenChat) {
      HStack {
        VStack(alignment: .leading, spacing: 6) {
          Text(item.name)
            .textStyle(.title5)
            .foregroundColor(.gray900)

          Text(item.statusText)
            .textStyle(.caption7)
            .foregroundColor(.gray500)
        }

        Spacer()

        Text("대화 보기 ›")
          .textStyle(.body5)
          .foregroundColor(.gray900)
      }
      .padding(.vertical, 14)
      .frame(minHeight: 64)
      .contentShape(Rectangle())
      .overlay(alignment: .top) {
        Rectangle().fill(Color.gray100).frame(height: 1)
      }
    }
    .buttonStyle(.plain)
  }
}

#Preview {
  VStack(spacing: 16) {
    ChatCard(items: [
      ChatCardItem(id: "1", name: "카야잼", statusText: ActivityStatusBadge.inProgressBadge.text, onOpenChat: {})
    ])
    ChatCard(items: [
      ChatCardItem(id: "1", name: "성실한치타", statusText: ActivityStatusBadge.waitingBadge.text, onOpenChat: {}),
      ChatCardItem(id: "2", name: "부지런한여우", statusText: ActivityStatusBadge.cancelledBadge.text, onOpenChat: {})
    ])
  }
  .padding(16)
  .background(Color.gray000)
}
