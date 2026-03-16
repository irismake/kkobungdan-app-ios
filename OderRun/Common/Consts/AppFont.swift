import SwiftUI

// MARK: - Line Height

enum OdrLineHeight {
  static let headline1: CGFloat = 44
  static let headline2: CGFloat = 36
  static let title1: CGFloat = 32
  static let title2: CGFloat = 30
  static let title3: CGFloat = 28
  static let title4: CGFloat = 26
  static let title5: CGFloat = 24
  static let body1: CGFloat = 24
  static let body2: CGFloat = 24
  static let body3: CGFloat = 20
  static let body4: CGFloat = 16
  static let caption1: CGFloat = 16
  static let caption2: CGFloat = 16
  static let paragraph: CGFloat = 1.6
}

// MARK: - Font Size

enum OdrFontSize {
  static let headline1: CGFloat = 36
  static let headline2: CGFloat = 28
  static let title1: CGFloat = 24
  static let title2: CGFloat = 22
  static let title3: CGFloat = 20
  static let title4: CGFloat = 18
  static let title5: CGFloat = 17
  static let body1: CGFloat = 16
  static let body2: CGFloat = 15
  static let body3: CGFloat = 14
  static let body4: CGFloat = 13
  static let caption1: CGFloat = 12
  static let caption2: CGFloat = 11
  static let paragraph: CGFloat = 14
}

// MARK: - Letter Spacing

enum OdrLetterSpacing {
  static let headline1: CGFloat = -0.25
  static let headline2: CGFloat = -0.2
  static let title1: CGFloat = -0.2
  static let title2: CGFloat = -0.44
  static let title3: CGFloat = -0.2
  static let title4: CGFloat = -0.2
  static let title5: CGFloat = -0.2
  static let body1: CGFloat = -0.31
  static let body2: CGFloat = -0.15
  static let body3: CGFloat = -0.14
  static let body4: CGFloat = -0.05
  static let caption1: CGFloat = 0
  static let caption2: CGFloat = 0
  static let paragraph: CGFloat = -0.28
}

// MARK: - WdTextStyle

struct OdrTextStyle {
  let font: Font
  let lineHeight: CGFloat
  let letterSpacing: CGFloat
  let color: Color
}

// MARK: - Font Extension

extension Font {
  static func pretendard(_ weight: Font.Weight, size: CGFloat) -> Font {
    Font.custom("Pretendard", size: size).weight(weight)
  }
}

// MARK: - WdTextStyle Factory

extension OdrTextStyle {
  static func headline1(weight: Font.Weight = .medium, color: Color = .primary) -> OdrTextStyle {
    OdrTextStyle(
      font: .pretendard(weight, size: OdrFontSize.headline1),
      lineHeight: OdrLineHeight.headline1,
      letterSpacing: OdrLetterSpacing.headline1,
      color: color
    )
  }

  static func headline2(weight: Font.Weight = .medium, color: Color = .primary) -> OdrTextStyle {
    OdrTextStyle(
      font: .pretendard(weight, size: OdrFontSize.headline2),
      lineHeight: OdrLineHeight.headline2,
      letterSpacing: OdrLetterSpacing.headline2,
      color: color
    )
  }

  static func title1(weight: Font.Weight = .medium, color: Color = .primary) -> OdrTextStyle {
    OdrTextStyle(
      font: .pretendard(weight, size: OdrFontSize.title1),
      lineHeight: OdrLineHeight.title1,
      letterSpacing: OdrLetterSpacing.title1,
      color: color
    )
  }

  static func title2(weight: Font.Weight = .medium, color: Color = .primary) -> OdrTextStyle {
    OdrTextStyle(
      font: .pretendard(weight, size: OdrFontSize.title2),
      lineHeight: OdrLineHeight.title2,
      letterSpacing: OdrLetterSpacing.title2,
      color: color
    )
  }

  static func title3(weight: Font.Weight = .medium, color: Color = .primary) -> OdrTextStyle {
    OdrTextStyle(
      font: .pretendard(weight, size: OdrFontSize.title3),
      lineHeight: OdrLineHeight.title3,
      letterSpacing: OdrLetterSpacing.title3,
      color: color
    )
  }

  static func title4(weight: Font.Weight = .medium, color: Color = .primary) -> OdrTextStyle {
    OdrTextStyle(
      font: .pretendard(weight, size: OdrFontSize.title4),
      lineHeight: OdrLineHeight.title4,
      letterSpacing: OdrLetterSpacing.title4,
      color: color
    )
  }

  static func title5(weight: Font.Weight = .medium, color: Color = .primary) -> OdrTextStyle {
    OdrTextStyle(
      font: .pretendard(weight, size: OdrFontSize.title5),
      lineHeight: OdrLineHeight.title5,
      letterSpacing: OdrLetterSpacing.title5,
      color: color
    )
  }

  static func body1(weight: Font.Weight = .regular, color: Color = .primary) -> OdrTextStyle {
    OdrTextStyle(
      font: .pretendard(weight, size: OdrFontSize.body1),
      lineHeight: OdrLineHeight.body1,
      letterSpacing: OdrLetterSpacing.body1,
      color: color
    )
  }

  static func body2(weight: Font.Weight = .regular, color: Color = .primary) -> OdrTextStyle {
    OdrTextStyle(
      font: .pretendard(weight, size: OdrFontSize.body2),
      lineHeight: OdrLineHeight.body2,
      letterSpacing: OdrLetterSpacing.body2,
      color: color
    )
  }

  static func body3(weight: Font.Weight = .regular, color: Color = .primary) -> OdrTextStyle {
    OdrTextStyle(
      font: .pretendard(weight, size: OdrFontSize.body3),
      lineHeight: OdrLineHeight.body3,
      letterSpacing: OdrLetterSpacing.body3,
      color: color
    )
  }

  static func body4(weight: Font.Weight = .regular, color: Color = .primary) -> OdrTextStyle {
    OdrTextStyle(
      font: .pretendard(weight, size: OdrFontSize.body4),
      lineHeight: OdrLineHeight.body4,
      letterSpacing: OdrLetterSpacing.body4,
      color: color
    )
  }

  static func caption1(weight: Font.Weight = .regular, color: Color = .primary) -> OdrTextStyle {
    OdrTextStyle(
      font: .pretendard(weight, size: OdrFontSize.caption1),
      lineHeight: OdrLineHeight.caption1,
      letterSpacing: OdrLetterSpacing.caption1,
      color: color
    )
  }

  static func caption2(weight: Font.Weight = .regular, color: Color = .primary) -> OdrTextStyle {
    OdrTextStyle(
      font: .pretendard(weight, size: OdrFontSize.caption2),
      lineHeight: OdrLineHeight.caption2,
      letterSpacing: OdrLetterSpacing.caption2,
      color: color
    )
  }

  static func paragraph(weight: Font.Weight = .regular, color: Color = .primary) -> OdrTextStyle {
    OdrTextStyle(
      font: .pretendard(weight, size: OdrFontSize.paragraph),
      lineHeight: OdrLineHeight.paragraph,
      letterSpacing: OdrLetterSpacing.paragraph,
      color: color
    )
  }
}

// MARK: - Text Extension

extension Text {
  func odrStyle(_ style: OdrTextStyle) -> some View {
    font(style.font)
      .kerning(style.letterSpacing)
      .lineSpacing(style.lineHeight)
      .foregroundColor(style.color)
  }
}

struct OdrTextFieldStyleModifier: ViewModifier {
  let style: OdrTextStyle

  func body(content: Content) -> some View {
    content
      .font(style.font)
      .kerning(style.letterSpacing)
      .foregroundColor(style.color)
  }
}

// MARK: - TextField Extension

extension View {
  func odrTextFieldStyle(_ style: OdrTextStyle) -> some View {
    modifier(OdrTextFieldStyleModifier(style: style))
  }
}
