//
//  MissionAbortCompleteView.swift
//  Kkobungdan
//
//  임무 중단 신청 접수 완료 화면.
//

import SwiftUI

struct MissionAbortCompleteView: View {
  var onHome: () -> Void = {}

  var body: some View {
    CompletionLayout(
      title: "임무 중단 완료",
      message: "임무 중단 신청이 정상적으로 접수되었습니다.\n환불이 필요한 경우 영업일 기준 3~5일 이내 환불 처리되며\n완료 시 알림을 보내드립니다.",
      onPrimary: onHome
    )
  }
}

#Preview {
  MissionAbortCompleteView()
}
