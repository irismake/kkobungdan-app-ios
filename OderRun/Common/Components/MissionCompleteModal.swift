import SwiftUI

struct MissionCompleteModal: View {
  let title: String
  let isApplicant: Bool
  let infoTitle: String
  var infoContent: String
  let onCancel: () -> Void
  let onConfirm: () -> Void

  private var description: String {
    isApplicant
      ? "요청자와 만나셨나요?\n요청자가 만남 확인 버튼을 누르면 웨이팅비가 지급됩니다."
      : "타임 세이퍼와 만나셨나요?\n세이퍼가 만남 확인 버튼을 누르면 보증금이 환급됩니다."
  }

  var body: some View {
    ZStack {
      Color.black.opacity(0.4)
        .ignoresSafeArea()
        .onTapGesture { onCancel() }

      VStack(spacing: 16) {
        ZStack {
          Circle()
            .fill(Color.emerald000)
            .frame(width: 48, height: 48)

          Image("icon_circle_check")
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
            .foregroundColor(Color.emerald500)
        }

        VStack(spacing: 4) {
          Text(title)
            .font(.custom("Pretendard-Bold", size: 18))
            .kerning(-0.4)
            .appLineHeight(28, fontName: "Pretendard-Bold", fontSize: 18)
            .foregroundColor(Color.gray900)
            .multilineTextAlignment(.center)

          Text(description)
            .font(.custom("Pretendard-Regular", size: 14))
            .kerning(-0.1)
            .appLineHeight(20, fontName: "Pretendard-Regular", fontSize: 14)
            .foregroundColor(Color.gray600)
            .multilineTextAlignment(.center)
        }

        HStack(alignment: .top, spacing: 4) {
          Image("icon_warning")
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: 16, height: 16)
            .foregroundColor(Color.amber500)

          VStack(alignment: .leading, spacing: 8) {
            Text(infoTitle)
              .font(.custom("Pretendard-SemiBold", size: 12))
              .kerning(-0.4)
              .appLineHeight(16, fontName: "Pretendard-SemiBold", fontSize: 12)
              .foregroundColor(Color.amber800)
                  
            Text(infoContent)
              .font(.custom("Pretendard-Regular", size: 12))
              .kerning(-0.1)
              .appLineHeight(16, fontName: "Pretendard-Regular", fontSize: 12)
              .foregroundColor(Color.amber800)
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.amber000)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
          RoundedRectangle(cornerRadius: 14)
            .stroke(Color.amber200, lineWidth: 1)
        )
          
        // Buttons
        HStack(spacing: 8) {
          Button(action: onCancel) {
            Text("취소")
              .font(.custom("Inter-Medium", size: 16))
              .kerning(-0.312)
              .appLineHeight(24, fontName: "Inter-Medium", fontSize: 16)
              .foregroundColor(Color.gray700)
              .multilineTextAlignment(.center)
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
            Text("확인")
              .font(.custom("Inter-Medium", size: 16))
              .kerning(-0.312)
              .appLineHeight(24, fontName: "Inter-Medium", fontSize: 16)
              .foregroundColor(.white)
              .multilineTextAlignment(.center)
              .frame(maxWidth: .infinity)
              .frame(height: 50)
              .background(Color.indigo500)
              .clipShape(RoundedRectangle(cornerRadius: 12))
          }
          .buttonStyle(.plain)
        }
      }
      .padding(.vertical, 24)
      .padding(.horizontal, 16)
      .background(Color.white)
      .clipShape(RoundedRectangle(cornerRadius: 16))
    }
  }
}

#Preview {
  MissionCompleteModal(
    title: "진행 완료 처리하시겠습니까?",
    isApplicant: false,
    infoTitle: "취소 안내",
    infoContent: "완료 처리 후 취소가 불가능하며 문제 발생 시 고객센터 이메일로 문의 부탁드립니다.",
    onCancel: {},
    onConfirm: {}
  )
}
