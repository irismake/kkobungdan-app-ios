//
//  View+ErrorToast.swift
//  Kkobungdan
//
//  Created by 김가희 on 7/23/26.
//

import SwiftUI

extension View {
  /// 에러 메시지를 하단 토스트로 잠깐 표시한다.
  /// 표시 시간이 지나면 자동으로 사라지며 메시지를 nil 로 되돌린다.
  func errorToast(_ errorMessage: Binding<String?>) -> some View {
    modifier(ErrorToastModifier(message: errorMessage))
  }
}

private struct ErrorToastModifier: ViewModifier {
  @Binding var message: String?

  /// 토스트 노출 시간.
  private static let displayDuration: UInt64 = 2_500_000_000

  func body(content: Content) -> some View {
    content
      .overlay(alignment: .bottom) {
        if let message {
          Text(message)
            .textStyle(.body3)
            .foregroundColor(Color.gray000)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.gray900.opacity(0.92))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            // 메시지가 바뀌면 타이머를 새로 시작한다.
            .task(id: message) {
              try? await Task.sleep(nanoseconds: Self.displayDuration)
              self.message = nil
            }
        }
      }
      .animation(.easeInOut(duration: 0.25), value: message)
  }
}
