//
//  ContentView.swift
//  OderRun
//
//  Created by 김가희 on 3/4/26.
//

import SwiftUI

struct ContentView: View {
  @Environment(SessionViewModel.self) private var session

  var body: some View {
    Group {
      if session.isLoggedIn {
        HomeContainerView()
      } else {
        AuthFlowView()
      }
    }
    .onReceive(NotificationCenter.default.publisher(for: .authForcedLogout)) { _ in
      session.isLoggedIn = false
    }
  }
}

#Preview {
  ContentView()
    .environment(SessionViewModel())
}
