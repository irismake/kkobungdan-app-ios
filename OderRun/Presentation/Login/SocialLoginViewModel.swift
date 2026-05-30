//
//  SocialLoginViewModel.swift
//  OderRun
//
//  Created by 김가희 on 3/4/26.
//

import Foundation

@Observable
final class SocialLoginViewModel {
  var email: String = ""
  var password: String = ""
  var isLoading: Bool = false
  var errorMessage: String?
  var isLoginSuccess: Bool

  var isAppleLoading: Bool = false
  var isKakaoLoading: Bool = false
  var isTermsSheetPresented: Bool = false

  private let emailLoginUseCase: EmailLoginUseCase
  private let appleLoginUseCase: AppleLoginUseCase
  private let kakaoLoginUseCase: KakaoLoginUseCase
  private let appleSignInController: AppleSignInController
  private let kakaoSignInController: KakaoSignInController

  init(
    emailLoginUseCase: EmailLoginUseCase,
    appleLoginUseCase: AppleLoginUseCase,
    kakaoLoginUseCase: KakaoLoginUseCase,
    appleSignInController: AppleSignInController = AppleSignInController(),
    kakaoSignInController: KakaoSignInController = KakaoSignInController(),
    tokenStorage: TokenStorage = .shared
  ) {
    self.emailLoginUseCase = emailLoginUseCase
    self.appleLoginUseCase = appleLoginUseCase
    self.kakaoLoginUseCase = kakaoLoginUseCase
    self.appleSignInController = appleSignInController
    self.kakaoSignInController = kakaoSignInController
    // 저장된 refresh token 이 있으면 이미 로그인된 상태로 시작.
    // refresh token 도 만료됐다면 첫 API 호출의 401 → refresh 실패 → forceLogout 으로 복귀.
    // 더미 모드는 토큰 발급 경로가 없으므로 로그인 화면을 건너뛴다.
    isLoginSuccess = DIContainer.isDummy || tokenStorage.refreshToken != nil
  }

  @MainActor
  func login() async {
    guard !email.isEmpty, !password.isEmpty else {
      errorMessage = "이메일과 비밀번호를 입력해주세요."
      return
    }

    isLoading = true
    errorMessage = nil

    do {
      _ = try await emailLoginUseCase.execute(email: email, password: password)
      isLoginSuccess = true
    } catch {
      errorMessage = "로그인에 실패했습니다. 다시 시도해주세요."
    }

    isLoading = false
  }

  @MainActor
  func appleLogin() async {
    guard !isAppleLoading else {
      return
    }
    isAppleLoading = true
    errorMessage = nil

    do {
      let credential = try await appleSignInController.requestSignIn()
      let result = try await appleLoginUseCase.execute(
        identityToken: credential.identityToken,
        name: credential.name,
        email: credential.email
      )
      if result.profileSyncRequired {
        isTermsSheetPresented = true
      } else {
        isLoginSuccess = true
      }
    } catch AppleSignInError.canceled {
      // 사용자가 취소한 경우는 조용히 무시
    } catch {
      errorMessage = "Apple 로그인에 실패했습니다. 잠시 후 다시 시도해주세요."
    }

    isAppleLoading = false
  }

  @MainActor
  func kakaoLogin() async {
    guard !isKakaoLoading else {
      return
    }
    isKakaoLoading = true
    errorMessage = nil

    do {
      let accessToken = try await kakaoSignInController.requestSignIn()
      let result = try await kakaoLoginUseCase.execute(accessToken: accessToken)
      if result.profileSyncRequired {
        isTermsSheetPresented = true
      } else {
        isLoginSuccess = true
      }
    } catch KakaoSignInError.canceled {
      // 사용자가 취소한 경우는 조용히 무시
    } catch {
      errorMessage = "카카오 로그인에 실패했습니다. 잠시 후 다시 시도해주세요."
    }

    isKakaoLoading = false
  }

  @MainActor
  func completeTermsAgreement() {
    isTermsSheetPresented = false
    isLoginSuccess = true
  }

  func clearError() {
    errorMessage = nil
  }
}
