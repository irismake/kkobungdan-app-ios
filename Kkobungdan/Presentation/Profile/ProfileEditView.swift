//
//  ProfileEditView.swift
//  Kkobungdan
//
//  Created by 김가희 on 5/30/26.
//

import SwiftUI

struct ProfileEditView: View {
  let initialNickname: String
  let onClose: () -> Void
  let onSave: (String) -> Void

  @State private var nickname: String

  init(
    initialNickname: String,
    onClose: @escaping () -> Void,
    onSave: @escaping (String) -> Void
  ) {
    self.initialNickname = initialNickname
    self.onClose = onClose
    self.onSave = onSave
    _nickname = State(initialValue: initialNickname)
  }

  private var trimmedNickname: String {
    nickname.trimmingCharacters(in: .whitespaces)
  }

  /// 변경이 일어났고 빈 값이 아닐 때만 수정 가능.
  private var canSave: Bool {
    !trimmedNickname.isEmpty && trimmedNickname != initialNickname
  }

  var body: some View {
    VStack(spacing: 0) {
      CloseHeader(title: "닉네임 수정", onClose: onClose)
        .padding(.top, 8)
        .padding(.bottom, 32)

      LabeledFieldContainer(label: "이름") {
        FocusTextField(
          text: $nickname,
          placeholder: "닉네임을 입력해 주세요",
          autoFocus: true
        )
      }
      .padding(.horizontal, Layout.screenHorizontalPadding)

      Spacer(minLength: 0)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.white)
    .ignoresSafeArea(.keyboard, edges: .bottom)
    .safeAreaInset(edge: .bottom, spacing: 0) {
      BottomActionBar(title: "수정", isEnabled: canSave) {
        onSave(trimmedNickname)
      }
    }
  }
}

#Preview {
  ProfileEditView(initialNickname: "뉴비23", onClose: {}, onSave: { _ in })
}
