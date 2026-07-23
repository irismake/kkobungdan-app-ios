//
//  WithdrawCompleteView.swift
//  Kkobungdan
//
//  회원 탈퇴 완료 화면. 신고 접수·임무 중단 완료와 동일 디자인이라 `CompletionLayout` 을 공유한다.
//  "완료" 를 누르면 강제 로그아웃되어 로그인 화면으로 이동한다.
//

import SwiftUI

struct WithdrawCompleteView: View {
  var onComplete: () -> Void = {}

  var body: some View {
    CompletionLayout(
      title: "회원 탈퇴가 완료되었어요.",
      message: "오늘은 여기까지!\n언젠가 다시 임무가 생기면\n꼭 다시 만나요 🙏",
      buttonTitle: "완료",
      onPrimary: onComplete
    )
  }
}

#Preview {
  WithdrawCompleteView()
}
