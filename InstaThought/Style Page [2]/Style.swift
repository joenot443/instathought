//
//  Style.swift
//  InstaThought
//
//  Created by Joe Crozier on 9/9/24.
//

import Foundation
import SwiftUI
import Combine

class Style: ObservableObject {
  
  @Published var foregroundColor: Color
  @Published var backgroundColor: Color
  @Published var fontSize: CGFloat
  @Published var padding: CGFloat
  @Published var lineHeight: CGFloat
  @Published var fontName: String
  @Published var shape: Shape
  @Published var textAlignment: TextAlignmentOption
  
  func scaledTo(scale: CGFloat) -> Style {
    Style(
      foregroundColor: self.foregroundColor,
      backgroundColor: self.backgroundColor,
      fontSize: self.fontSize * scale,
      padding: self.padding * scale,
      lineHeight: self.lineHeight * scale,
      fontName: self.fontName,
      shape: self.shape,
      textAlignment: self.textAlignment
    )
  }
  
  private var cancellables: Set<AnyCancellable> = []
  
  init(foregroundColor: Color, backgroundColor: Color, fontSize: CGFloat, padding: CGFloat = 8, lineHeight: CGFloat = 1.2, fontName: String = "Helvetica", shape: Shape = .insta, textAlignment: TextAlignmentOption = .left) {
    self.foregroundColor = foregroundColor
    self.backgroundColor = backgroundColor
    self.fontSize = fontSize
    self.padding = padding
    self.lineHeight = lineHeight
    self.fontName = fontName
    self.shape = shape
    self.textAlignment = .left
  }
}

enum Shape {
  case insta, square, fullscreen
  
  mutating func advance() {
    switch self {
    case .insta:
      self = .square
    case .square:
      self = .fullscreen
    case .fullscreen:
      self = .insta
    }
  }
  
  func icon() -> String {
    switch self {
    case .fullscreen:
      return "rectangle.portrait.fill"
    case .insta:
      return "rectangle.portrait.center.inset.filled"
    case .square:
      return "square.fill"
    }
  }
}

enum TextAlignmentOption {
  case left, center, right, justified
  
  mutating func advance() {
    switch self {
    case .left:
      self = .center
    case .center:
      self = .right
    case .right:
      self = .justified
    case .justified:
      self = .left
    }
  }
  
  func alignment() -> NSTextAlignment {
    switch self {
    case .left:
      return .left
    case .center:
      return .center
    case .right:
      return .right
    case .justified:
      return .justified
    }
  }
  
  func icon() -> Image {
    switch self {
    case .left:
      return Image(systemName: "text.alignleft")
    case .center:
      return Image(systemName: "text.aligncenter")
    case .right:
      return Image(systemName: "text.alignright")
    case .justified:
      return Image(systemName: "text.justify")
    }
  }

  func name() -> String {
    switch self {
    case .left:
      return "Left"
    case .center:
      return "Center"
    case .right:
      return "Right"
    case .justified:
      return "Justified"
    }
  }
}

extension Style {
  static var defaultStyle: Style = .init(foregroundColor:  Theme.shared.colors.secondaryText, backgroundColor: Theme.shared.colors.primaryBackground, fontSize: 24.0)
  
  static var templateStyle: Style = .init(foregroundColor:  UITraitCollection.current.userInterfaceStyle == .dark ? .white.opacity(0.6) : .black.opacity(0.5), backgroundColor: .clear, fontSize: 16.0, shape: .fullscreen)
  
  static let defaultPaddings: [CGFloat] = [0, 8, 16, 24, 32, 48, 64, 82]
  
  static let defaultLineHeights: [CGFloat] = [1.0, 1.2, 1.5, 2.0, 2.5, 3.5]
  
  static let defaultStyles: [Style] = [
    Style(foregroundColor: Color(r: 240, g: 214, b: 187), backgroundColor: Color(r: 53, g: 53, b: 53), fontSize: 28.0, fontName: "SourceSans3-Roman_Regular"),
    Style(foregroundColor: Color(r: 226, g: 223, b: 218), backgroundColor: Color(r: 38, g: 38, b: 38), fontSize: 28.0, fontName: "QuattrocentoSans"),
    Style(foregroundColor: Color(r: 249, g: 246, b: 239), backgroundColor: Color(r: 109, g: 106, b: 101), fontSize: 28.0, fontName: "FanwoodText-Regular"),
    Style(foregroundColor: Color(r: 38, g: 25, b: 17), backgroundColor: Color(r: 249, g: 246, b: 239), fontSize: 28.0, fontName: "QuattrocentoSans"),
    Style(foregroundColor: Color(r: 42, g: 46, b: 47), backgroundColor: Color(r: 220, g: 221, b: 215), fontSize: 28.0, fontName: "LibreBaskerville-Regular"),
    Style(foregroundColor: Color(r: 245, g: 240, b: 236), backgroundColor: Color(r: 0, g: 0, b: 0), fontSize: 28.0, fontName: "Lato-Regular"),
    Style(foregroundColor: Color(r: 33, g: 29, b: 30), backgroundColor: Color(r: 233, g: 230, b: 225), fontSize: 28.0, fontName: "ProzaLibre-Regular"),
    Style(foregroundColor: Color(r: 249, g: 249, b: 249), backgroundColor: Color(r: 51, g: 47, b: 48), fontSize: 28.0, fontName: "EBGaramond-Regular"),
    Style(foregroundColor: Color(r: 235, g: 235, b: 235), backgroundColor: Color(r: 55, g: 66, b: 88), fontSize: 28.0, fontName: "SourceSans3-Roman_Regular"),
    Style(foregroundColor: Color(r: 219, g: 204, b: 181), backgroundColor: Color(r: 181, g: 104, b: 76), fontSize: 28.0, fontName: "FaunaOne-Regular"),
    Style(foregroundColor: Color(r: 80, g: 49, b: 47), backgroundColor: Color(r: 219, g: 204, b: 181), fontSize: 28.0, fontName: "Alice-Regular"),
    Style(foregroundColor: Color(r: 219, g: 169, b: 136), backgroundColor: Color(r: 22, g: 44, b: 58), fontSize: 28.0, fontName: "JosefinSansRoman-Regular"),
    Style(foregroundColor: Color(r: 27, g: 59, b: 70), backgroundColor: Color(r: 235, g: 221, b: 212), fontSize: 28.0, fontName: "MontserratRoman-Regular"),
    Style(foregroundColor: Color(r: 219, g: 172, b: 111), backgroundColor: Color(r: 123, g: 51, b: 52), fontSize: 28.0, fontName: "JosefinSansRoman-Regular"),
    Style(foregroundColor: Color(r: 33, g: 29, b: 30), backgroundColor: Color(r: 233, g: 230, b: 225), fontSize: 28.0, fontName: "Roboto-Regular"),
    Style(foregroundColor: Color(r: 85, g: 85, b: 83), backgroundColor: Color(r: 238, g: 221, b: 211), fontSize: 28.0, fontName: "Karla-Regular"),
    Style(foregroundColor: Color(r: 251, g: 245, b: 245), backgroundColor: Color(r: 45, g: 44, b: 42), fontSize: 28.0, fontName: "Merriweather-Regular"),
    Style(foregroundColor: Color(r: 35, g: 31, b: 32), backgroundColor: Color(r: 173, g: 142, b: 121), fontSize: 28.0, fontName: "Nunito-Regular"),
    Style(foregroundColor: Color(r: 15, g: 12, b: 19), backgroundColor: Color(r: 230, g: 225, b: 222), fontSize: 28.0, fontName: "Quicksand-Regular"),
    Style(foregroundColor: Color(r: 235, g: 224, b: 218), backgroundColor: Color(r: 60, g: 53, b: 43), fontSize: 28.0, fontName: "OpenSans-Regular"),
    Style(foregroundColor: Color(r: 101, g: 108, b: 116), backgroundColor: Color(r: 238, g: 237, b: 232), fontSize: 28.0, fontName: "Hind-Medium"),
    Style(foregroundColor: Color(r: 236, g: 232, b: 231), backgroundColor: Color(r: 46, g: 54, b: 65), fontSize: 28.0, fontName: "PTSans-Regular"),
    Style(foregroundColor: Color(r: 221, g: 225, b: 236), backgroundColor: Color(r: 46, g: 54, b: 65), fontSize: 28.0, fontName: "Merriweather-Regular"),
    Style(foregroundColor: Color(r: 55, g: 57, b: 69), backgroundColor: Color(r: 220, g: 221, b: 225), fontSize: 28.0, fontName: "Cardo-Regular"),
    Style(foregroundColor: Color(r: 222, g: 221, b: 221), backgroundColor: Color(r: 15, g: 9, b: 9), fontSize: 28.0, fontName: "CrimsonText-Regular"),
    Style(foregroundColor: Color(r: 245, g: 245, b: 253), backgroundColor: Color(r: 96, g: 77, b: 255), fontSize: 28.0, fontName: "OpenSans-Regular"),
    Style(foregroundColor: Color(r: 253, g: 191, b: 45), backgroundColor: Color(r: 39, g: 39, b: 39), fontSize: 28.0, fontName: "Nunito-Regular"),
    Style(foregroundColor: Color(r: 3, g: 5, b: 4), backgroundColor: Color(r: 151, g: 235, b: 212), fontSize: 28.0, fontName: "Lato-Regular"),
    Style(foregroundColor: Color(r: 37, g: 31, b: 84), backgroundColor: Color(r: 209, g: 200, b: 255), fontSize: 28.0, fontName: "Poppins-Medium"),
    Style(foregroundColor: Color(r: 251, g: 233, b: 234), backgroundColor: Color(r: 251, g: 74, b: 84), fontSize: 28.0, fontName: "SourceSans3-Roman_Regular"),
    Style(foregroundColor: Color(r: 232, g: 233, b: 240), backgroundColor: Color(r: 48, g: 48, b: 75), fontSize: 28.0, fontName: "Inconsolata-Regular"),
    Style(foregroundColor: Color(r: 0, g: 0, b: 0), backgroundColor: Color(r: 250, g: 201, b: 187), fontSize: 28.0, fontName: "Slabo27px-Regular"),
    Style(foregroundColor: Color(r: 14, g: 21, b: 21), backgroundColor: Color(r: 236, g: 238, b: 240), fontSize: 28.0, fontName: "Ledger-Regular"),
    Style(foregroundColor: Color(r: 245, g: 255, b: 254), backgroundColor: Color(r: 73, g: 192, b: 212), fontSize: 28.0, fontName: "PontanoSans-Regular"),
    Style(foregroundColor: Color(r: 248, g: 214, b: 184), backgroundColor: Color(r: 119, g: 56, b: 25), fontSize: 28.0, fontName: "Andika"),
    Style(foregroundColor: Color(r: 249, g: 250, b: 251), backgroundColor: Color(r: 46, g: 46, b: 50), fontSize: 28.0, fontName: "CrimsonText-Regular"),
    Style(foregroundColor: Color(r: 249, g: 250, b: 251), backgroundColor: Color(r: 254, g: 98, b: 57), fontSize: 28.0, fontName: "Mulish-Regular"),
    Style(foregroundColor: Color(r: 240, g: 228, b: 216), backgroundColor: Color(r: 45, g: 45, b: 43), fontSize: 28.0, fontName: "SourceSerif4-Regular"),
    Style(foregroundColor: Color(r: 255, g: 255, b: 255), backgroundColor: Color(r: 176, g: 168, b: 157), fontSize: 28.0, fontName: "Cantarell-Regular"),
    Style(foregroundColor: Color(r: 230, g: 230, b: 231), backgroundColor: Color(r: 88, g: 74, b: 68), fontSize: 28.0, fontName: "OpenSans-Regular"),
    Style(foregroundColor: Color(r: 174, g: 144, b: 115), backgroundColor: Color(r: 243, g: 242, b: 242), fontSize: 28.0, fontName: "OpenSans-Regular"),
    Style(foregroundColor: Color(r: 0, g: 0, b: 0), backgroundColor: Color(r: 251, g: 242, b: 233), fontSize: 28.0, fontName: "OpenSans-Regular"),
    Style(foregroundColor: Color(r: 249, g: 249, b: 249), backgroundColor: Color(r: 128, g: 132, b: 141), fontSize: 28.0, fontName: "SourceSans3-Roman_Regular"),
    Style(foregroundColor: Color(r: 234, g: 236, b: 248), backgroundColor: Color(r: 205, g: 180, b: 150), fontSize: 28.0, fontName: "Cabin-Regular"),
    Style(foregroundColor: Color(r: 255, g: 255, b: 255), backgroundColor: Color(r: 179, g: 180, b: 184), fontSize: 28.0, fontName: "Cabin-Regular"),
    Style(foregroundColor: Color(r: 249, g: 249, b: 249), backgroundColor: Color(r: 45, g: 45, b: 43), fontSize: 28.0, fontName: "OpenSans-Regular"),
    Style(foregroundColor: Color(r: 179, g: 180, b: 184), backgroundColor: Color(r: 128, g: 132, b: 141), fontSize: 28.0, fontName: "Lora-Medium")
  ]
}

extension Color {
  init(r: Int, g: Int, b: Int) {
    self.init(red: Double(r) / 255.0, green: Double(g) / 255.0, blue: Double(b) / 255.0)
  }
}
