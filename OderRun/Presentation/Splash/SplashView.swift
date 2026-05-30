//
//  SplashView.swift
//  OderRun
//
//  Created by 김가희 on 5/30/26.
//

import SwiftUI

struct SplashView: View {
  var body: some View {
    ZStack {
      Color.white
        .ignoresSafeArea()

      Image("logo")
        .resizable()
        .scaledToFit()
        .frame(width: 353, height: 353)
        .offset(y: -42)
    }
  }
}

#Preview {
  SplashView()
}
