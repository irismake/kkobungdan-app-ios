//
//  AppUpdateModal.swift
//  Kkobungdan
//

import SwiftUI

/// 강제/선택 업데이트 안내 모달.
/// - 강제(`isForced == true`): 배경 탭·닫기 불가. 업데이트 버튼만 노출.
/// - 선택(`isForced == false`): "나중에" 로 닫고 계속 사용 가능.
struct AppUpdateModal: View {
  let isForced: Bool
  let message: String
  let onUpdate: () -> Void
  var onLater: (() -> Void)?

  var body: some View {
    ZStack {
      Color.black.opacity(0.4)
        .ignoresSafeArea()
        .onTapGesture {
          // 선택 업데이트만 배경 탭으로 닫기 허용.
          if !isForced {
            onLater?()
          }
        }

      VStack(spacing: 0) {
        ZStack {
          Circle()
            .fill(Color.indigo000)
            .frame(width: 48, height: 48)

          Image(systemName: "arrow.down.circle.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 26, height: 26)
            .foregroundColor(Color.indigo500)
        }

        Text(isForced ? "업데이트가 필요해요" : "새 버전이 나왔어요 🎉")
          .textStyle(.heading3, weight: .bold)
          .foregroundColor(Color.gray900)
          .multilineTextAlignment(.center)
          .padding(.top, 16)

        Text(message)
          .textStyle(.body3)
          .foregroundColor(Color.gray600)
          .multilineTextAlignment(.center)
          .fixedSize(horizontal: false, vertical: true)
          .padding(.top, 14)

        buttons
          .padding(.top, 26)
      }
      .padding(.top, 24)
      .padding(.horizontal, 16)
      .padding(.bottom, 16)
      .background(Color.white)
      .clipShape(RoundedRectangle(cornerRadius: 16))
      .padding(.horizontal, Layout.screenHorizontalPadding)
    }
  }

  @ViewBuilder
  private var buttons: some View {
    if isForced {
      updateButton
    } else {
      HStack(spacing: 8) {
        Button(action: { onLater?() }) {
          Text("나중에")
            .textStyle(.body1)
            .foregroundColor(Color.gray700)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
              RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray300, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)

        updateButton
      }
    }
  }

  private var updateButton: some View {
    Button(action: onUpdate) {
      Text("업데이트하기")
        .textStyle(.body1)
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(Color.indigo500)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    .buttonStyle(.plain)
  }
}

#Preview("강제") {
  AppUpdateModal(
    isForced: true,
    message: CheckAppUpdateUseCase.defaultForceMessage,
    onUpdate: {}
  )
}

#Preview("선택") {
  AppUpdateModal(
    isForced: false,
    message: CheckAppUpdateUseCase.defaultOptionalMessage,
    onUpdate: {},
    onLater: {}
  )
}
