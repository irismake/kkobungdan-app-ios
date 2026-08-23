import SwiftUI
import UIKit

extension View {
  /// CSS `line-height`처럼 "목표 줄높이"에 가깝게 맞추기 위한 헬퍼.
  /// SwiftUI의 `lineSpacing`은 '추가 간격'이라, 폰트 메트릭(`UIFont.lineHeight`) 기반으로 보정한다.
  func appLineHeight(_ targetLineHeight: CGFloat, fontName: String, fontSize: CGFloat) -> some View {
    let uiFont = UIFont(name: fontName, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    let extra = max(0, targetLineHeight - uiFont.lineHeight)
    return lineSpacing(extra)
      .padding(.vertical, extra / 2)
  }

  func appLineHeight(_ targetLineHeight: CGFloat, uiFont: UIFont) -> some View {
    let extra = max(0, targetLineHeight - uiFont.lineHeight)
    return lineSpacing(extra)
      .padding(.vertical, extra / 2)
  }
}
