//
//  ActionListSheet.swift
//  Kkobungdan
//

import SwiftUI

/// 액션 목록 바텀시트의 항목 한 줄.
struct ActionListSheetItem: Identifiable {
  let title: String
  /// 지원 취소처럼 되돌리기 어려운 액션은 빨간 글씨로 표시한다.
  var isDestructive: Bool = false
  let action: () -> Void

  var id: String {
    title
  }
}

/// 제목·부제 아래에 액션 목록과 '닫기' 버튼을 두는 바텀시트. (예: 채팅 관리 메뉴)
/// 항목을 탭하면 시트가 닫힌 뒤 해당 액션을 실행한다.
struct ActionListSheet: View {
  let title: String
  var subtitle: String?
  let items: [ActionListSheetItem]
  let onClose: () -> Void

  @State private var isShown = false
  @State private var dragOffset: CGFloat = 0

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

      VStack(alignment: .leading, spacing: 16) {
        Text(title)
          .textStyle(.heading7)
          .foregroundColor(.gray900)

        if let subtitle {
          Text(subtitle)
            .textStyle(.caption7)
            .foregroundColor(.gray500)
            .lineLimit(1)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.horizontal, 24)
      .padding(.top, 8)
      .padding(.bottom, 12)

      VStack(spacing: 0) {
        ForEach(items) { item in
          itemRow(item)
        }
      }
      .padding(.horizontal, 16)

      OutlineButton(title: "닫기") { close(onClose) }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
    .frame(maxWidth: .infinity)
    .background(
      UnevenRoundedRectangle(topLeadingRadius: 12, topTrailingRadius: 12)
        .fill(Color.white)
        .ignoresSafeArea(edges: .bottom)
    )
  }

  private func itemRow(_ item: ActionListSheetItem) -> some View {
    Button { close(item.action) } label: {
      Text(item.title)
        .textStyle(.body5)
        .foregroundColor(item.isDestructive ? .rose500 : .gray900)
        .frame(maxWidth: .infinity, minHeight: 55, alignment: .leading)
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .overlay(alignment: .bottom) {
      Rectangle().fill(Color.gray200).frame(height: 1)
    }
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
    ActionListSheet(
      title: "채팅 관리",
      subtitle: "성수동 행님 · 성수 베이커리 소금빵 웨이팅",
      items: [
        ActionListSheetItem(title: "상단에 고정") {},
        ActionListSheetItem(title: "알림 끄기") {},
        ActionListSheetItem(title: "대화 보관하기") {},
        ActionListSheetItem(title: "지원 취소", isDestructive: true) {},
        ActionListSheetItem(title: "대화 신고") {}
      ],
      onClose: {}
    )
  }
}
