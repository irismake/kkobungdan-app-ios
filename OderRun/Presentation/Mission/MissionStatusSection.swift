//
//  MissionStatusSection.swift
//  OderRun
//
//  Created by 김가희 on 4/27/26.
//

import SwiftUI

/// 의뢰자/러너 상세 화면에 끼워 넣는 미션 상태 + 액션 버튼 섹션.
/// 매칭된 미션이 없으면 아무것도 그리지 않는다.
struct MissionStatusSection: View {
  @Bindable var viewModel: MissionDetailViewModel

  var body: some View {
    if let mission = viewModel.mission {
      VStack(alignment: .leading, spacing: 12) {
        statusHeader(mission: mission)

        feeRow(label: "심부름비", value: mission.runFee)
        if mission.itemPrice > 0 {
          feeRow(label: "상품 비용", value: mission.itemPrice)
        }

        if !viewModel.availableActions.isEmpty {
          Divider().background(Color.gray200)
          actionButtons
        }

        if let errorMessage = viewModel.errorMessage {
          Text(errorMessage)
            .textStyle(.body3)
            .foregroundColor(Color.rose500)
        }
      }
      .padding(16)
      .background(Color.white)
      .clipShape(RoundedRectangle(cornerRadius: 10))
      .overlay(
        RoundedRectangle(cornerRadius: 10)
          .stroke(Color.gray200, lineWidth: 1)
      )
    }
  }

  private func statusHeader(mission: Mission) -> some View {
    HStack(spacing: 8) {
      Text("미션 상태")
        .textStyle(.body2, weight: .bold)
        .foregroundColor(Color.gray800)

      let badge = MissionDisplay.statusBadge(mission.status)
      Badge(text: badge.text, textColor: badge.textColor, bgColor: badge.bgColor)

      Spacer()
    }
  }

  private func feeRow(label: String, value: Int) -> some View {
    HStack {
      Text(label)
        .textStyle(.body3)
        .foregroundColor(Color.gray600)
      Spacer()
      Text(ProposalDisplay.feeString(value))
        .textStyle(.body2, weight: .bold)
        .foregroundColor(Color.gray900)
    }
  }

  private var actionButtons: some View {
    HStack(spacing: 8) {
      ForEach(viewModel.availableActions, id: \.rawValue) { action in
        actionButton(for: action)
      }
    }
  }

  private func actionButton(for action: MissionAction) -> some View {
    let style = buttonStyle(for: action)
    return Button {
      Task { await viewModel.performAction(action) }
    } label: {
      Text(viewModel.isUpdating ? "처리 중..." : style.title)
        .textStyle(.body2, weight: .bold)
        .foregroundColor(style.foreground)
        .frame(maxWidth: .infinity)
        .frame(height: 44)
        .background(style.background)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(style.border, lineWidth: 1)
        )
    }
    .buttonStyle(.plain)
    .disabled(viewModel.isUpdating)
  }

  private func buttonStyle(
    for action: MissionAction
  ) -> (title: String, foreground: Color, background: Color, border: Color) {
    switch action {
    case .startProgress:
      return ("진행 시작", .white, .indigo500, .indigo500)
    case .completeDelivery:
      return ("전달 완료", .white, .emerald500, .emerald500)
    case .confirmReceived:
      return ("수령 확인", .white, .indigo500, .indigo500)
    case .dispute:
      return ("분쟁 신고", .rose500, .white, .rose200)
    }
  }
}
