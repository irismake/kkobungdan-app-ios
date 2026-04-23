import SwiftUI

struct ProfileView: View {
  @State private var viewModel: ProfileViewModel

  private let appVersion = "v1.0.0"
  private let supportEmail = "email@gmail"

  init(viewModel: ProfileViewModel) {
    _viewModel = State(initialValue: viewModel)
  }

  private var nickname: String {
    viewModel.runnerProfile?.nickname ?? viewModel.user?.name ?? "{닉네임}"
  }

  private var level: Int {
    viewModel.runnerProfile?.level ?? 1
  }

  private var grade: String {
    viewModel.runnerProfile?.grade ?? "{등급}"
  }

  var body: some View {
    VStack(spacing: 0) {
      TabPageHeader(title: "프로필")

      VStack(spacing: 12) {
        profileCard
          .padding(.horizontal, 16)

        // 메뉴 섹션 (border-t 컨테이너)
        VStack(spacing: 0) {
          VStack(spacing: 16) {
            // 약관 & 버전 그룹
            VStack(spacing: 0) {
              termsRow
              versionRow
            }

            // 로그아웃
            logoutRow
          }

          Spacer()

          customerSupportCard
        }
        .frame(maxHeight: .infinity)
        .overlay(alignment: .top) {
          Rectangle().fill(Color.gray200).frame(height: 1)
        }
      }
      .padding(.top, 16)
      .background(Color.gray000)
      .frame(maxHeight: .infinity)
    }
    .task {
      await viewModel.load()
    }
  }

  // MARK: - Profile Card

  private var profileCard: some View {
    VStack(alignment: .leading, spacing: 24) {
      Text(nickname)
        .font(.custom("Pretendard-SemiBold", size: 18))
        .kerning(-0.4)
        .appLineHeight(18, fontName: "Pretendard-SemiBold", fontSize: 18)
        .foregroundColor(Color.black)

      VStack(alignment: .leading, spacing: 2) {
        Text("웨이팅 레벨")
          .font(.custom("Pretendard-Regular", size: 12))
          .kerning(-0.15)
          .appLineHeight(20, fontName: "Pretendard-Regular", fontSize: 12)
          .foregroundColor(Color.gray500)

        HStack(spacing: 6) {
          Image("icon_users")
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: 16, height: 16)
            .foregroundColor(Color.amber500)

          Text("Lv \(level): \(grade)")
            .font(.custom("Pretendard-Medium", size: 14))
            .kerning(-0.15)
            .appLineHeight(20, fontName: "Pretendard-Medium", fontSize: 14)
            .foregroundColor(Color.gray900)
        }
      }
    }
    .padding(.horizontal, 16)
    .padding(.top, 16)
    .padding(.bottom, 20)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color.white)
    .clipShape(RoundedRectangle(cornerRadius: 10))
    .overlay(
      RoundedRectangle(cornerRadius: 10)
        .stroke(Color.gray200, lineWidth: 1)
    )
  }

  // MARK: - Menu Rows

  private var termsRow: some View {
    HStack(spacing: 12) {
      HStack(spacing: 8) {
        Image(systemName: "doc.text")
          .resizable()
          .scaledToFit()
          .frame(width: 20, height: 20)
          .foregroundColor(Color.gray900)

        Text("약관 및 정책")
          .font(.custom("Pretendard-SemiBold", size: 14))
          .kerning(-0.4)
          .appLineHeight(14, fontName: "Pretendard-SemiBold", fontSize: 14)
          .foregroundColor(Color.gray900)

        Spacer()
      }

      Image("icon_arrow_right")
        .renderingMode(.template)
        .resizable()
        .scaledToFit()
        .frame(width: 20, height: 20)
        .foregroundColor(Color.gray400)
    }
    .padding(.horizontal, 24)
    .padding(.vertical, 20)
    .background(Color.white)
    .overlay(alignment: .bottom) {
      Rectangle().fill(Color.gray200).frame(height: 1)
    }
  }

  private var versionRow: some View {
    HStack(spacing: 12) {
      HStack(spacing: 8) {
        Image("icon_info")
          .renderingMode(.template)
          .resizable()
          .scaledToFit()
          .frame(width: 20, height: 20)
          .foregroundColor(Color.gray900)

        Text("버전 정보")
          .font(.custom("Pretendard-SemiBold", size: 14))
          .kerning(-0.4)
          .appLineHeight(14, fontName: "Pretendard-SemiBold", fontSize: 14)
          .foregroundColor(Color.gray900)

        Spacer()
      }

      Text(appVersion)
        .font(.custom("Pretendard-Medium", size: 14))
        .kerning(-0.1)
        .appLineHeight(20, fontName: "Pretendard-Medium", fontSize: 14)
        .foregroundColor(Color.gray600)
    }
    .padding(.horizontal, 24)
    .padding(.vertical, 20)
    .background(Color.white)
    .overlay(alignment: .bottom) {
      Rectangle().fill(Color.gray200).frame(height: 1)
    }
  }

  private var logoutRow: some View {
    HStack(spacing: 8) {
      Image(systemName: "rectangle.portrait.and.arrow.right")
        .resizable()
        .scaledToFit()
        .frame(width: 20, height: 20)
        .foregroundColor(Color.rose500)

      Text("로그아웃")
        .font(.custom("Pretendard-SemiBold", size: 14))
        .kerning(-0.4)
        .appLineHeight(14, fontName: "Pretendard-SemiBold", fontSize: 14)
        .foregroundColor(Color.rose500)

      Spacer()
    }
    .padding(.horizontal, 24)
    .padding(.vertical, 20)
    .background(Color.white)
    .overlay(alignment: .top) {
      Rectangle().fill(Color.gray200).frame(height: 1)
    }
    .overlay(alignment: .bottom) {
      Rectangle().fill(Color.gray200).frame(height: 1)
    }
  }

  // MARK: - Customer Support

  private var customerSupportCard: some View {
    VStack(alignment: .leading, spacing: 10) {
      VStack(alignment: .leading, spacing: 2) {
        Text("고객 센터")
          .font(.custom("Pretendard-SemiBold", size: 14))
          .kerning(-0.4)
          .appLineHeight(14, fontName: "Pretendard-SemiBold", fontSize: 14)
          .foregroundColor(Color.gray900)

        Text("아래 이메일로 문의 부탁드립니다.")
          .font(.custom("Pretendard-Regular", size: 12))
          .kerning(-0.1)
          .appLineHeight(14, fontName: "Pretendard-Regular", fontSize: 12)
          .foregroundColor(Color.gray600)
      }

      Text(supportEmail)
        .font(.custom("Pretendard-Regular", size: 14))
        .kerning(-0.1)
        .appLineHeight(20, fontName: "Pretendard-Regular", fontSize: 14)
        .foregroundColor(Color.gray700)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(16)
    .background(Color.white)
    .overlay(alignment: .top) {
      Rectangle().fill(Color.gray200).frame(height: 1)
    }
  }
}

#Preview {
  ProfileView(viewModel: .preview())
}
