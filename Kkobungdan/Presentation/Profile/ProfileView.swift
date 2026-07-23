import SwiftUI

struct ProfileView: View {
  @Environment(SessionViewModel.self) private var session
  @State private var viewModel: ProfileViewModel

  private let appVersion = "v1.0.0"
  private let supportEmail = SupportContact.email

  init(viewModel: ProfileViewModel) {
    _viewModel = State(initialValue: viewModel)
  }

  private var nickname: String {
    viewModel.user?.name ?? ""
  }

  private var level: Int {
    viewModel.user?.level ?? 0
  }

  @State private var isEditingProfile = false
  @State private var isWithdrawing = false
  @State private var isWithdrawReasonPresented = false

  var body: some View {
    ZStack {
      profileContent

      if isWithdrawing {
        WithdrawConfirmModal(
          onCancel: { isWithdrawing = false },
          onConfirm: {
            isWithdrawing = false
            isWithdrawReasonPresented = true
          }
        )
      }
    }
    .fullScreenCover(isPresented: $isWithdrawReasonPresented) {
      WithdrawReasonView(
        onClose: { isWithdrawReasonPresented = false },
        onSubmitted: {
          // TODO: 탈퇴 완료 화면 연결 (presentation only)
          isWithdrawReasonPresented = false
        }
      )
    }
  }

  private var profileContent: some View {
    VStack(spacing: 0) {
      TabPageHeader(title: "프로필")

      VStack(spacing: 12) {
        profileCard
          .padding(.horizontal, 16)

        // 메뉴 섹션 (border-t 컨테이너)
        VStack(spacing: 0) {
          VStack(spacing: 16) {
            // 약관 & 버전 & 알림 설정 그룹
            VStack(spacing: 0) {
              termsRow
              versionRow
              alarmRow
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
    .onChange(of: viewModel.didLogout) { _, didLogout in
      if didLogout {
        session.isLoggedIn = false
      }
    }
    .fullScreenCover(isPresented: $isEditingProfile) {
      ProfileEditView(
        initialNickname: nickname,
        onClose: { isEditingProfile = false },
        onSave: { newNickname in
          isEditingProfile = false
          Task { await viewModel.updateName(newNickname) }
        }
      )
    }
  }

  // MARK: - Profile Card

  private var profileCard: some View {
    VStack(alignment: .leading, spacing: 20) {
      UserInfoHeader(name: nickname, level: level, spacing: 24)

      editProfileButton
    }
    .padding(16)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color.white)
    .clipShape(RoundedRectangle(cornerRadius: 10))
    .overlay(
      RoundedRectangle(cornerRadius: 10)
        .stroke(Color.gray200, lineWidth: 1)
    )
  }

  private var editProfileButton: some View {
    Button {
      isEditingProfile = true
    } label: {
      Text("프로필 수정")
        .textStyle(.button1)
        .foregroundColor(Color.gray800)
        .frame(maxWidth: .infinity)
        .frame(height: 32)
        .background(Color.gray100)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
    .buttonStyle(.plain)
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
          .textStyle(.title3)
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
          .textStyle(.title3)
          .foregroundColor(Color.gray900)

        Spacer()
      }

      Text(appVersion)
        .textStyle(.body2)
        .foregroundColor(Color.gray600)
    }
    .padding(.horizontal, 24)
    .padding(.vertical, 20)
    .background(Color.white)
    .overlay(alignment: .bottom) {
      Rectangle().fill(Color.gray200).frame(height: 1)
    }
  }

  /// 서버 알림 수신 설정(`alarmEnabled`) 토글. 꺼져 있으면 서버가 푸시를 생성하지 않는다.
  private var alarmRow: some View {
    HStack(spacing: 12) {
      HStack(spacing: 8) {
        Image(systemName: "bell")
          .resizable()
          .scaledToFit()
          .frame(width: 20, height: 20)
          .foregroundColor(Color.gray900)

        Text("알림 설정")
          .textStyle(.title3)
          .foregroundColor(Color.gray900)

        Spacer()
      }

      Toggle("알림 설정", isOn: alarmBinding)
        .labelsHidden()
        .tint(Color.indigo500)
        .disabled(viewModel.user == nil)
        .frame(height: 20)
    }
    .padding(.horizontal, 24)
    .padding(.vertical, 20)
    .background(Color.white)
    .overlay(alignment: .bottom) {
      Rectangle().fill(Color.gray200).frame(height: 1)
    }
  }

  /// 표시는 user.alarmEnabled 를 따르고, 변경 시 서버 반영(`PATCH /v1/user/alarm`) 후
  /// 응답으로 user 가 갱신된다. 실패하면 user 가 그대로라 토글이 원래 상태로 돌아온다.
  private var alarmBinding: Binding<Bool> {
    Binding(
      get: { viewModel.user?.alarmEnabled ?? false },
      set: { enabled in
        Task { await viewModel.toggleAlarm(enabled) }
      }
    )
  }

  private var logoutRow: some View {
    Button {
      Task { await viewModel.logout() }
    } label: {
      HStack(spacing: 8) {
        Image(systemName: "rectangle.portrait.and.arrow.right")
          .resizable()
          .scaledToFit()
          .frame(width: 20, height: 20)
          .foregroundColor(Color.rose500)

        Text("로그아웃")
          .textStyle(.title3)
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
    .buttonStyle(.plain)
    .disabled(viewModel.isLoading)
  }

  // MARK: - Customer Support

  private var customerSupportCard: some View {
    VStack(alignment: .leading, spacing: 10) {
      VStack(alignment: .leading, spacing: 2) {
        Text("고객 센터")
          .textStyle(.title3)
          .foregroundColor(Color.gray900)

        Text("아래 이메일로 문의 부탁드립니다.")
          .textStyle(.caption6)
          .foregroundColor(Color.gray600)
      }

      Text(supportEmail)
        .textStyle(.body3)
        .foregroundColor(Color.gray700)

      withdrawButton
        .padding(.top, 10)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(16)
    .background(Color.white)
    .overlay(alignment: .top) {
      Rectangle().fill(Color.gray200).frame(height: 1)
    }
  }

  private var withdrawButton: some View {
    Button {
      isWithdrawing = true
    } label: {
      Text("탈퇴하기")
        .textStyle(.button2)
        .foregroundColor(Color.gray700)
        .underline()
    }
    .buttonStyle(.plain)
  }
}

#Preview {
  ProfileView(viewModel: .preview())
}
