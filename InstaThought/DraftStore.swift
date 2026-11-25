//
//  DraftStore.swift
//  InstaThought
//
//  Remembers the current thought and the last style between launches.
//

import SwiftUI
import UIKit

enum DraftStore {
  private static let textKey = "draft.text"
  private static let styleKey = "draft.style"
  private static var defaults: UserDefaults { .standard }

  static func loadText() -> String {
    defaults.string(forKey: textKey) ?? ""
  }

  static func saveText(_ text: String) {
    defaults.set(text, forKey: textKey)
  }

  static func loadStyle() -> Style? {
    guard let data = defaults.data(forKey: styleKey),
          let stored = try? JSONDecoder().decode(StoredStyle.self, from: data) else {
      return nil
    }
    return stored.makeStyle()
  }

  static func saveStyle(_ style: Style) {
    guard let data = try? JSONEncoder().encode(StoredStyle(style)) else { return }
    defaults.set(data, forKey: styleKey)
  }

  static func clear() {
    defaults.removeObject(forKey: textKey)
    defaults.removeObject(forKey: styleKey)
  }
}

/// A Codable snapshot of `Style` (which holds SwiftUI `Color`s and isn't Codable itself).
private struct StoredStyle: Codable {
  struct RGBA: Codable {
    var r, g, b, a: Double

    init(_ color: Color) {
      var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
      UIColor(color).getRed(&r, green: &g, blue: &b, alpha: &a)
      self.r = r; self.g = g; self.b = b; self.a = a
    }

    var color: Color { Color(.sRGB, red: r, green: g, blue: b, opacity: a) }
  }

  var foreground: RGBA
  var background: RGBA
  var fontSize: Double
  var padding: Double
  var verticalPadding: Double
  var lineHeight: Double
  var fontName: String
  var shape: String
  var textAlignment: String

  init(_ style: Style) {
    foreground = RGBA(style.foregroundColor)
    background = RGBA(style.backgroundColor)
    fontSize = style.fontSize
    padding = style.padding
    verticalPadding = style.verticalPadding
    lineHeight = style.lineHeight
    fontName = style.fontName
    shape = String(describing: style.shape)
    textAlignment = String(describing: style.textAlignment)
  }

  func makeStyle() -> Style {
    let style = Style(
      foregroundColor: foreground.color,
      backgroundColor: background.color,
      fontSize: fontSize,
      padding: padding,
      verticalPadding: verticalPadding,
      lineHeight: lineHeight,
      fontName: fontName,
      shape: Shape.allCases.first { String(describing: $0) == shape } ?? .insta
    )
    // Style.init always sets alignment to .left, so restore it afterwards.
    style.textAlignment = TextAlignmentOption.allCases.first { String(describing: $0) == textAlignment } ?? .left
    return style
  }
}
