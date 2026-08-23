import SwiftUI

struct WithdrawConfirmModal: View {
  let onCancel: () -> Void
  let onConfirm: () -> Void

  private let infoItems = [
    "개인정보는 개인정보처리방침에 따라 삭제됩니다.",
    "거래 및 정산 기록은 관련 법령에 따라 일정 기간 보관될 수 있습니다.",
    "진행 중인 임무나 정산이 있는 경우 탈퇴가 제한될 수 있습니다.",
    "동일한 휴대폰 번호로 다시 가입할 수 있지만 이전 활동 내역은 복구되지 않습니다."
  ]

  var body: some View {
    ZStack {
      Color.black.opacity(0.4)
        .ignoresSafeArea()
        .onTapGesture { onCancel() }

      VStack(spacing: 0) {
        ZStack {
          Circle()
            .fill(Color.rose000)
            .frame(width: 48, height: 48)

          Image("icon_wavy_warning_empty")
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
            .foregroundColor(Color.rose500)
        }

        Text("꼬붕단을 떠나시겠어요? 🥺")
          .textStyle(.heading3, weight: .bold)
          .foregroundColor(Color.gray900)
          .multilineTextAlignment(.center)
          .padding(.top, 16)

        Text("회원 탈퇴 전 아래 내용을 꼭 확인해 주세요.")
          .textStyle(.body3)
          .foregroundColor(Color.gray600)
          .multilineTextAlignment(.center)
          .padding(.top, 14)

        infoBox
          .padding(.top, 26)

        HStack(spacing: 8) {
          Button(action: onCancel) {
            Text("취소")
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

          Button(action: onConfirm) {
            Text("탈퇴 진행")
              .textStyle(.body1)
              .foregroundColor(.white)
              .frame(maxWidth: .infinity)
              .frame(height: 50)
              .background(Color.rose500)
              .clipShape(RoundedRectangle(cornerRadius: 12))
          }
          .buttonStyle(.plain)
        }
        .padding(.top, 16)
      }
      .padding(.top, 24)
      .padding(.horizontal, 16)
      .padding(.bottom, 16)
      .background(Color.white)
      .clipShape(RoundedRectangle(cornerRadius: 16))
      .padding(.horizontal, Layout.screenHorizontalPadding)
    }
  }

  private var infoBox: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("안내")
        .textStyle(.caption4, kerning: 0)
        .foregroundColor(Color.blue900)

      VStack(alignment: .leading, spacing: 14) {
        ForEach(infoItems, id: \.self) { item in
          HStack(alignment: .top, spacing: 6) {
            Text("•")
              .textStyle(.body3)
              .foregroundColor(Color.blue500)

            Text(item)
              .textStyle(.body3, kerning: 0)
              .foregroundColor(Color.blue900)
              .frame(maxWidth: .infinity, alignment: .leading)
          }
        }
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(16)
    .background(Color.blue000)
    .clipShape(RoundedRectangle(cornerRadius: 14))
    .overlay(
      RoundedRectangle(cornerRadius: 14)
        .stroke(Color.blue200, lineWidth: 1)
    )
  }
}

#Preview {
  WithdrawConfirmModal(onCancel: {}, onConfirm: {})
}
