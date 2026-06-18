//
//  AddProposalView.swift
//  OderRun
//
//  Created by 김가희 on 3/4/26.
//

import SwiftUI

struct AddProposalView: View {
  @State private var title: String
  @State private var content: String

  private let initialDraft: AddProposalDraft
  let onBack: () -> Void
  let onNext: (AddProposalDraft) -> Void

  init(
    draft: AddProposalDraft = AddProposalDraft(),
    onBack: @escaping () -> Void = {},
    onNext: @escaping (AddProposalDraft) -> Void = { _ in }
  ) {
    initialDraft = draft
    _title = State(initialValue: draft.title)
    _content = State(initialValue: draft.content)
    self.onBack = onBack
    self.onNext = onNext
  }

  private var isNextEnabled: Bool {
    !title.isEmpty && !content.isEmpty
  }

  var body: some View {
    VStack(spacing: 0) {
      headerSection

      scrollContent

      bottomSection
    }
    .background(Color.gray000)
    .navigationBarHidden(true)
  }

  private var headerSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      AppBar(progress: (1, 3), onBack: onBack)

      VStack(alignment: .leading, spacing: 8) {
        Text("기본 정보 작성")
          .textStyle(.heading3)
          .foregroundColor(Color.gray900)
          .padding(.horizontal, 16)

        Text("제목과 내용을 입력해주세요")
          .textStyle(.body3)
          .foregroundColor(Color.gray600)
          .padding(.horizontal, 16)
      }
    }
    .padding(.bottom, 32)
    .overlay(alignment: .bottom) {
      Divider()
        .frame(height: 1)
        .foregroundColor(Color.gray200)
    }
  }

  private var scrollContent: some View {
    ScrollView {
      VStack(spacing: 24) {
        titleField
        contentField
      }
      .padding(16)
    }
  }

  private var titleField: some View {
    LabeledFieldContainer(label: "제목") {
      FocusTextField(
        text: $title,
        placeholder: "예: 성수동 OO 베이커리 소금빵 웨이팅",
        maxLength: 50,
        autoFocus: true
      )
    }
  }

  private var contentField: some View {
    LabeledFieldContainer(label: "내용") {
      ContentTextField(
        placeholder: "만남 장소를 포함한 요청 내용을 자세히 작성해주세요",
        text: $content,
        maxLength: 500
      )
    }
  }

  private var bottomSection: some View {
    BottomActionBar(title: "다음", isEnabled: isNextEnabled) {
      UIApplication.shared.endEditing()
      var updated = initialDraft
      updated.title = title
      updated.content = content
      onNext(updated)
    }
  }
}

#Preview {
  AddProposalView()
}
