//
//  ReportCompleteView.swift
//  Kkobungdan
//
//  신고 접수 완료 화면.
//

import SwiftUI

struct ReportCompleteView: View {
  var onHome: () -> Void = {}

  var body: some View {
    CompletionLayout(
      title: "신고 접수 완료",
      message: "운영팀이 신고 내용을 확인하고\n필요한 조치가 진행될 예정입니다.\n함께 안전한 커뮤니티를 만들어 주셔서 감사합니다.",
      onPrimary: onHome
    )
  }
}

#Preview {
  ReportCompleteView()
}
