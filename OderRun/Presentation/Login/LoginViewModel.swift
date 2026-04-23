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

  private let loginUseCase: LoginUseCase

  init(loginUseCase: LoginUseCase) {
    self.loginUseCase = loginUseCase
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

  func clearError() {
    errorMessage = nil
  }
}
