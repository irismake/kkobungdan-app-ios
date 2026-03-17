//
//  ContentView.swift
//  OderRun
//
//  Created by 김가희 on 3/4/26.
//

import SwiftUI

struct ContentView: View {
  private let loginViewModel = LoginViewModel(
    loginUseCase: LoginUseCase(authRepository: AuthRepositoryImpl())
  )

  var body: some View {
    ScreenContainer {
      LoginView(viewModel: loginViewModel)
    }
  }
}

#Preview {
  ContentView()
}
