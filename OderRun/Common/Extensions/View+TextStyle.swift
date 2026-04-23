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
  case heading1Compact // SemiBold 24/24/-0.4
  case heading2 // SemiBold 18/28/-0.4
  case heading3 // SemiBold 16/24/-0.2
  case title1 // SemiBold 18/18/-0.4 (compact)
  case title2 // SemiBold 14/20/-0.4
  case title3 // SemiBold 14/14/-0.4 (tight menu labels)
  case body1 // Medium 16/24/-0.3
  case body2 // Medium 14/20/-0.1
  case body3 // Regular 14/20/-0.1
  case caption1 // Medium 12/20/-0.1
  case caption1Tight // Medium 12/16/0
  case caption2 // Regular 12/20/-0.15
  case caption3 // SemiBold 12/16/-0.4
  case caption4 // Regular 12/16/0
  case caption4Compact // Regular 12/14/-0.1
  case inputBody1 // Pretendard-Regular 16/20/-0.2
  case accountBody2 // Pretendard-Medium 14/17/-0.2
  case accountBody1 // Pretendard-Medium 16/19/-0.2
  case interHeading1 // Medium 16/24/-0.312
  case interBody1 // Regular 16/24/-0.312

  var fontName: String {
    switch self {
    case .display:
      return "Pretendard-Bold"
    case .heading1, .heading1Compact, .heading2, .heading3, .title1, .title2, .title3, .caption3:
      return "Pretendard-SemiBold"
    case .body1, .body2, .caption1, .caption1Tight, .accountBody2, .accountBody1:
      return "Pretendard-Medium"
    case .body3, .caption2, .caption4, .caption4Compact, .inputBody1:
      return "Pretendard-Regular"
    case .interHeading1:
      return "Inter-Medium"
    case .interBody1:
      return "Inter-Regular"
    }
  }

  var fontSize: CGFloat {
    switch self {
    case .display: return 30
    case .heading1, .heading1Compact: return 24
    case .heading2, .title1: return 18
    case .heading3, .body1, .interHeading1, .interBody1, .inputBody1, .accountBody1: return 16
    case .title2, .title3, .body2, .body3, .accountBody2: return 14
    case .caption1, .caption1Tight, .caption2, .caption3, .caption4, .caption4Compact: return 12
    }
  }

  var lineHeight: CGFloat {
    switch self {
    case .display: return 36
    case .heading1: return 28
    case .heading1Compact: return 24
    case .heading2: return 28
    case .heading3: return 24
    case .title1: return 18
    case .title2: return 20
    case .title3: return 14
    case .body1: return 24
    case .body2: return 20
    case .body3: return 20
    case .caption1: return 20
    case .caption1Tight: return 16
    case .caption2: return 20
    case .caption3: return 16
    case .caption4: return 16
    case .caption4Compact: return 14
    case .inputBody1: return 20
    case .accountBody2: return 17
    case .accountBody1: return 19
    case .interHeading1, .interBody1: return 24
    }
  }

  var kerning: CGFloat {
    switch self {
    case .display: return 0.396
    case .heading1, .heading1Compact, .heading2, .title1, .title2, .title3, .caption3:
      return -0.4
    case .interHeading1, .interBody1: return -0.312
    case .body1: return -0.3
    case .heading3, .inputBody1, .accountBody2, .accountBody1: return -0.2
    case .caption2: return -0.15
    case .body2, .body3, .caption1, .caption4Compact: return -0.1
    case .caption1Tight, .caption4: return 0
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
