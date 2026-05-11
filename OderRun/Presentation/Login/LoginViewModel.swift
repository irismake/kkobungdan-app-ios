//
//  LoginViewModel.swift
//  OderRun
//
//  Created by 김가희 on 3/4/26.
//

import Foundation

@Observable
final class LoginViewModel {
  var email: String = ""
  var password: String = ""
  var isLoading: Bool = false
  var errorMessage: String?
  var isLoginSuccess: Bool = true

  var isAppleLoading: Bool = false
  var isTermsSheetPresented: Bool = false

  private let loginUseCase: LoginUseCase
  private let appleLoginUseCase: AppleLoginUseCase
  private let appleSignInController: AppleSignInController

  init(
    loginUseCase: LoginUseCase,
    appleLoginUseCase: AppleLoginUseCase,
    appleSignInController: AppleSignInController = AppleSignInController()
  ) {
    self.loginUseCase = loginUseCase
    self.appleLoginUseCase = appleLoginUseCase
    self.appleSignInController = appleSignInController
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
      _ = try await loginUseCase.execute(email: email, password: password)
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
        authorizationCode: credential.authorizationCode,
        userName: credential.userName
      )
      if result.isFirstLogin {
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
  func completeTermsAgreement() {
    isTermsSheetPresented = false
    isLoginSuccess = true
  }

  func clearError() {
    errorMessage = nil
  }
}
