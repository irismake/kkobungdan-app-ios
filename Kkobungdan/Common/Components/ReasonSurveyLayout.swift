//
//  ReasonSurveyLayout.swift
//  Kkobungdan
//
//  "라디오 사유 선택 + 상세 사유 + 제출" 공통 레이아웃.
//  임무 중단·신고·탈퇴가 동일 디자인이라 이 표현 컴포넌트를 공유한다.
//  데이터 로딩·선택·제출 로직은 각 화면 VM 이 담당하고, 이 뷰는 표현만 한다.
//

import SwiftUI

struct ReasonSurveyLayout: View {
  struct Option: Identifiable {
    let id: Int64
    let text: String
  }

  let title: String
  let subtitle: String
  let submitTitle: String
  let submittingTitle: String
  let options: [Option]
  let selectedID: Int64?
  @Binding var detail: String
  let detailMaxLength: Int
  let isSubmitting: Bool
  let canSubmit: Bool
  let onClose: () -> Void
  let onSelect: (Int64) -> Void
  let onSubmit: () -> Void

  /// 상세 사유 입력 활성 조건 — 사유를 하나 선택하면 열린다.
  private var isDetailEnabled: Bool {
    selectedID != nil
  }

  var body: some View {
    VStack(spacing: 0) {
      VStack(alignment: .leading, spacing: 12) {
        CloseHeader(
          title: title,
          closePosition: .trailing,
          onClose: onClose
        )

        Text(subtitle)
          .textStyle(.body3)
          .foregroundColor(Color.gray600)
          .padding(.horizontal, Layout.screenHorizontalPadding)
      }
      .padding(.bottom, 32)
      .overlay(alignment: .bottom) {
        Rectangle()
          .fill(Color.gray200)
          .frame(height: 1)
      }

      ScrollView {
        VStack(alignment: .leading, spacing: 24) {
          VStack(spacing: 10) {
            ForEach(options) { option in
              optionRow(option)
            }
          }

          LabeledFieldContainer(label: "상세 사유") {
            ContentTextField(
              placeholder: "기타를 선택하신 경우 상세 사유를 꼭 작성해 주세요.",
              text: $detail,
              maxLength: detailMaxLength
            )
            // 사유를 고르면 어떤 사유든 상세 작성이 가능하다. (기타만 작성 '필수')
            .disabled(!isDetailEnabled)
            .opacity(isDetailEnabled ? 1 : 0.5)
          }
        }
        .padding(Layout.screenHorizontalPadding)
      }

      VStack(spacing: 0) {
        FillButton(
          title: isSubmitting ? submittingTitle : submitTitle,
          isEnabled: canSubmit && !isSubmitting
        ) {
          onSubmit()
        }
        .padding(.horizontal, Layout.screenHorizontalPadding)
        .padding(.top, 16)
        .padding(.bottom, 20)
      }
      .frame(maxWidth: .infinity)
      .background(Color.white)
      .overlay(alignment: .top) {
        Rectangle()
          .fill(Color.gray200)
          .frame(height: 1)
      }
    }
    .background(Color.white)
  }

  private func optionRow(_ option: Option) -> some View {
    let isSelected = selectedID == option.id
    return Button {
      onSelect(option.id)
    } label: {
      HStack(spacing: 14) {
        radioCircle(isSelected: isSelected)

        Text(option.text)
          .textStyle(.body2, weight: isSelected ? .bold : nil, kerning: -0.2)
          .foregroundColor(isSelected ? Color.indigo800 : Color.gray800)

        Spacer(minLength: 0)
      }
      .padding(16)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(isSelected ? Color.indigo000 : Color.white)
      .clipShape(RoundedRectangle(cornerRadius: 16))
      .overlay(
        RoundedRectangle(cornerRadius: 16)
          .stroke(isSelected ? Color.indigo400 : Color.gray200, lineWidth: 1)
      )
    }
    .buttonStyle(.plain)
  }

  private func radioCircle(isSelected: Bool) -> some View {
    ZStack {
      Circle()
        .stroke(isSelected ? Color.indigo500 : Color.gray300, lineWidth: 2)
        .frame(width: 20, height: 20)

      if isSelected {
        Circle()
          .fill(Color.indigo500)
          .frame(width: 10, height: 10)
      }
    }
  }
}
