//
//  FloatingActionButton.swift
//  OderRun
//
//  Created by 김가희 on 3/26/26.
//

import SwiftUI

struct FloatingActionButton: View {
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Image("icon_plus")
        .renderingMode(.template)
        .resizable()
        .frame(width: 28, height: 28)
        .foregroundColor(.white)
        .frame(width: 56, height: 56)
        .background(Color.gray900)
        .clipShape(Circle())
        .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 10)
        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 4)
    }
  }
}

#Preview {
  ZStack(alignment: .bottomTrailing) {
    Color.gray000.ignoresSafeArea()
    FloatingActionButton(action: {})
      .padding(16)
  }
}
