//
//  MeetButton.swift
//  OderRun
//
//  Created by 김가희 on 5/30/26.
//

import SwiftUI

/// 의뢰자가 러너를 만났음을 확정하는 버튼. ConfirmButton 과 동일한 레이아웃에 emerald 강조 색상을 사용한다.
struct MeetButton: View {
  var title: String = "임무 수행 완료"
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Text(title)
        .textStyle(.heading4)
        .foregroundColor(.white)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(Color.emerald500)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    .buttonStyle(.plain)
  }
}

#Preview {
  MeetButton {}
    .padding()
}
