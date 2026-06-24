//
//  MissionAbortView.swift
//  OderRun
//
//  임무 중단 사유 선택 화면. 중단 사유 라디오 선택 + 상세 사유 작성 후 중단을 신청한다.
//  TODO: ViewModel·UseCase 연동 — 현재는 뷰만 구현(로컬 상태)이다.
//

import SwiftUI

struct MissionAbortView: View {
  /// 중단 사유 목록. TODO: 서버 연동 시 ViewModel에서 주입.
  private let reasons = [
    "임무를 진행하기 어려워졌어요",
    "꼬붕과 연락이 되지 않아요",
    "임무 수행이 어렵다고 전달받았어요",
    "직접 해결하게 되었어요",
    "기타",
  ]

  @State private var selectedReason: String?
  @State private var detail: String = ""

  var onClose: () -> Void = {}
  var onSubmit: () -> Void = {}

  static let detailMaxLength = 500

  private var requiresDetail: Bool {
    selectedReason?.contains("기타") ?? false
  }

  private var canSubmit: Bool {
    guard selectedReason != nil else {
      return false
    }
    if requiresDetail {
      return !detail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    return true
  }

  var body: some View {
    VStack(spacing: 0) {
      VStack(alignment: .leading, spacing: 12) {
        CloseHeader(
          title: "어떤 이유로 임무를 중단하시나요?",
          closePosition: .trailing,
          onClose: onClose
        )

        Text("임무 진행 상황에 따라 수행비가 정산될 수 있어요.")
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
            ForEach(reasons, id: \.self) { reason in
              reasonRow(reason)
            }
          }

          LabeledFieldContainer(label: "상세 사유") {
            ContentTextField(
              placeholder: "기타를 선택하신 경우 상세 사유를 꼭 작성해 주세요.",
              text: $detail,
              maxLength: MissionAbortView.detailMaxLength
            )
          }
        }
        .padding(Layout.screenHorizontalPadding)
      }

      VStack(spacing: 0) {
        FillButton(
          title: "임무 중단하기",
          isEnabled: canSubmit
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

  private func reasonRow(_ reason: String) -> some View {
    let isSelected = selectedReason == reason
    return Button {
      selectedReason = reason
    } label: {
      HStack(spacing: 14) {
        radioCircle(isSelected: isSelected)

        Text(reason)
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

#Preview {
  MissionAbortView()
}
