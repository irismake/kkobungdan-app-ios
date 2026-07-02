import SwiftUI

/// 매칭 성사 후 상세 화면에 노출되는 카카오톡 오픈채팅방 안내 카드.
/// `openChatURL` 이 있는 엔티티(`ProposalDetail`·`OfferDetail`)에서만 표시한다.
struct OpenChatModal: View {
  let urlString: String

  @Environment(\.openURL) private var openURL

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      VStack(alignment: .leading, spacing: 8) {
        HStack(spacing: 6) {
          Image("icon_chat")
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: 16, height: 16)
            .foregroundColor(Color.amber500)

          Text("카카오톡 오픈 채팅방 안내")
            .textStyle(.body2, weight: .bold)
            .foregroundColor(Color.amber800)
        }

        Text("오픈채팅방에서 임무에 대해 자세히 이야기해 보세요.")
          .textStyle(.body3)
          .foregroundColor(Color.amber800)
      }

      Button {
        if let url = URL(string: urlString) {
          openURL(url)
        }
      } label: {
        Text(urlString)
          .textStyle(.body4)
          .underline()
          .foregroundColor(Color.blue600)
          .lineLimit(1)
          .truncationMode(.middle)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.horizontal, 16)
          .frame(height: 47)
          .background(Color.white)
          .clipShape(RoundedRectangle(cornerRadius: 10))
          .overlay(
            RoundedRectangle(cornerRadius: 10)
              .stroke(Color.amber200, lineWidth: 1)
          )
      }
      .buttonStyle(.plain)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(16)
    .background(Color.amber000)
    .clipShape(RoundedRectangle(cornerRadius: 14))
    .overlay(
      RoundedRectangle(cornerRadius: 14)
        .stroke(Color.amber200, lineWidth: 1)
    )
  }
}

#Preview {
  OpenChatModal(urlString: "https://open.kakao.com/o/dummyChatRoom")
    .padding()
}
