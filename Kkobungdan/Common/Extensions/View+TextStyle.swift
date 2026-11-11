import SwiftUI

enum AppFontWeight {
  case regular
  case medium
  case semiBold
  case bold

  var fontName: String {
    switch self {
    case .regular: return "Pretendard-Regular"
    case .medium: return "Pretendard-Medium"
    case .semiBold: return "Pretendard-SemiBold"
    case .bold: return "Pretendard-Bold"
    }
  }
}

enum TextStyle {
  case display // Bold 30/36/+0.396
  case heading1 // SemiBold 24/28/-0.4
  case heading2 // SemiBold 24/24/-0.4
  case heading3 // SemiBold 18/28/-0.4
  case heading4 // SemiBold 16/24/-0.2
  case heading5 // SemiBold 16/28/-0.4
  case heading6 // Bold 20/28/-0.4
  case heading7 // Bold 18/26/-0.5
  case title1 // SemiBold 18/18/-0.4 (compact)
  case title2 // SemiBold 14/20/-0.4
  case title3 // SemiBold 14/14/-0.4 (tight menu labels)
  case title4 // Bold 14/20/0
  case body1 // Medium 16/24/-0.3
  case body2 // Medium 14/20/-0.1
  case body3 // Regular 14/20/-0.1
  case body4 // Regular 16/24/-0.312
  case body5 // Regular 14/22/0
  case caption1 // Medium 12/20/-0.1
  case caption2 // Regular 12/20/-0.15
  case caption3 // Medium 12/16/0
  case caption4 // SemiBold 12/16/-0.4
  case caption5 // Regular 12/16/0
  case caption6 // Regular 12/14/-0.1
  case caption7 // Regular 12/18/0
  case button1 // Medium 14/24/-0.2
  case button2 // Medium 14/14/-0.4 (line-height 100%)
  case badge1 // SemiBold 12/24/-0.2 (탭바 뱃지 숫자)
  case inputBody1 // Pretendard-Regular 16/20/-0.2
  case inputBody2 // Pretendard-Medium 14/17/-0.2
  case inputBody3 // Pretendard-Medium 16/19/-0.2
  case inputBody4 // Pretendard-Regular 16/16/-0.2 (입력 힌트, line-height 100%)

  var fontName: String {
    switch self {
    case .display, .heading6, .heading7, .title4:
      return "Pretendard-Bold"
    case .heading1, .heading2, .heading3, .heading4, .heading5, .title1, .title2, .title3, .caption4, .badge1:
      return "Pretendard-SemiBold"
    case .body1, .body2, .caption1, .caption3, .inputBody2, .inputBody3, .button1, .button2:
      return "Pretendard-Medium"
    case .body3, .body4, .body5, .caption2, .caption5, .caption6, .caption7, .inputBody1, .inputBody4:
      return "Pretendard-Regular"
    }
  }

  var fontSize: CGFloat {
    switch self {
    case .display: return 30
    case .heading1, .heading2: return 24
    case .heading6: return 20
    case .heading3, .heading7, .title1: return 18
    case .heading4, .heading5, .body1, .body4, .inputBody1, .inputBody3, .inputBody4: return 16
    case .title2, .title3, .title4, .body2, .body3, .body5, .inputBody2, .button1, .button2: return 14
    case .caption1, .caption3, .caption2, .caption4, .caption5, .caption6, .caption7, .badge1: return 12
    }
  }

  var lineHeight: CGFloat {
    switch self {
    case .display: return 36
    case .heading1, .heading6: return 28
    case .heading7: return 26
    case .heading2: return 24
    case .heading3: return 28
    case .heading4: return 24
    case .heading5: return 28
    case .title1: return 18
    case .title2, .title4: return 20
    case .title3: return 14
    case .body1: return 24
    case .body2: return 20
    case .body3: return 20
    case .body4: return 24
    case .body5: return 22
    case .button1: return 24
    case .button2: return 14
    case .badge1: return 24
    case .caption1: return 20
    case .caption3: return 16
    case .caption2: return 20
    case .caption4: return 16
    case .caption5: return 16
    case .caption6: return 14
    case .caption7: return 18
    case .inputBody1: return 20
    case .inputBody4: return 16
    case .inputBody2: return 17
    case .inputBody3: return 19
    }
  }

  var kerning: CGFloat {
    switch self {
    case .display: return 0.396
    case .heading1, .heading2, .heading3, .heading5, .heading6, .title1, .title2, .title3, .caption4, .button2:
      return -0.4
    case .heading7: return -0.5
    case .body4: return -0.312
    case .body1: return -0.3
    case .heading4, .inputBody1, .inputBody2, .inputBody3, .inputBody4, .button1, .badge1: return -0.2
    case .caption2: return -0.15
    case .body2, .body3, .caption1, .caption6: return -0.1
    case .caption3, .caption5, .caption7, .body5, .title4: return 0
    }
  }
}

extension View {
  func textStyle(
    _ style: TextStyle,
    weight: AppFontWeight? = nil,
    kerning: CGFloat? = nil,
    lineHeight: CGFloat? = nil
  ) -> some View {
    let fontName = weight?.fontName ?? style.fontName
    let kerning = kerning ?? style.kerning
    let lineHeight = lineHeight ?? style.lineHeight
    return font(.custom(fontName, size: style.fontSize))
      .kerning(kerning)
      .appLineHeight(lineHeight, fontName: fontName, fontSize: style.fontSize)
  }
}
