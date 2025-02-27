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
  
  private var cancellables: Set<AnyCancellable> = []
  
  init(foregroundColor: Color, backgroundColor: Color, fontSize: CGFloat, padding: CGFloat = 8, lineHeight: CGFloat = 1.2, fontName: String = "Helvetica") {
    self.foregroundColor = foregroundColor
    self.backgroundColor = backgroundColor
    self.fontSize = fontSize
    self.padding = padding
    self.lineHeight = lineHeight
    self.fontName = fontName
    self.shape = .insta
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
  case left, center, right
  
  mutating func advance() {
    switch self {
    case .left:
      self = .center
    case .center:
      self = .right
    case .right:
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
    }
  }
  
  func icon() -> String {
    switch self {
    case .left:
      return "text.alignleft"
    case .center:
      return "text.aligncenter"
    case .right:
      return "text.alignright"
    }
  }
}

extension Style {
  static var defaultStyle: Style = .init(foregroundColor: .black, backgroundColor: .white, fontSize: 24.0)
  
  static let defaultPaddings: [CGFloat] = [0, 8, 16, 24, 32, 48, 64, 82]
  
  static let defaultLineHeights: [CGFloat] = [1.0, 1.2, 1.5, 2.0, 2.5, 3.5]
}
