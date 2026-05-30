//
//  IdentityVerificationSheet.swift
//  OderRun
//
//  Created by 김가희 on 5/30/26.
//

import SwiftUI

/// 로그인·회원가입 진입 시 노출되는 본인인증 안내 바텀시트.
struct IdentityVerificationSheet: View {
  let onClose: () -> Void
  let onVerify: () -> Void

  @State private var isShown = false

  var body: some View {
    ZStack(alignment: .bottom) {
      Color.black.opacity(isShown ? 0.5 : 0)
        .ignoresSafeArea()
        .onTapGesture { close(onClose) }

      if isShown {
        sheet
          .transition(.move(edge: .bottom))
      }
    }
    .onAppear {
      withAnimation(.easeOut(duration: 0.25)) { isShown = true }
    }
  }

  private var sheet: some View {
    VStack(spacing: 0) {
      Capsule()
        .fill(Color.gray400)
        .frame(width: 40, height: 4)
        .padding(.top, 8)
        .padding(.bottom, 16)

      VStack(spacing: 12) {
        VStack(alignment: .leading, spacing: 0) {
          Text("안전한 꼬붕단 이용을 위해\n본인인증을 진행할게요")
            .textStyle(.heading4)
            .foregroundColor(.gray900)
            .fixedSize(horizontal: false, vertical: true)

          Text("믿을 수 있는 임무 매칭을 위해 본인인증이 필요해요")
            .textStyle(.body3)
            .foregroundColor(.gray600)
        }
        .frame(maxWidth: .infinity, alignment: .leading)

        Image("mascot_identify")
          .resizable()
          .scaledToFill()
          .frame(width: 192, height: 144)
          .clipped()
      }
      .padding(.horizontal, 24)
      .padding(.top, 8)

      Gap.v(16)
      BottomActionBar(title: "30초 만에 인증하기", action: { close(onVerify) })
    }
    .frame(maxWidth: .infinity)
    .background(
      UnevenRoundedRectangle(topLeadingRadius: 12, topTrailingRadius: 12)
        .fill(Color.white)
        .ignoresSafeArea(edges: .bottom)
    )
  }

  private func close(_ completion: @escaping () -> Void) {
    withAnimation(.easeIn(duration: 0.2)) {
      isShown = false
    } completion: {
      completion()
    }
  }
}

#Preview {
  ZStack {
    Color.gray000.ignoresSafeArea()
    IdentityVerificationSheet(onClose: {}, onVerify: {})
  }
}
