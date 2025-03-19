import SwiftUI

final class Theme: ObservableObject {
  static let shared = Theme()
  
  @Published private(set) var colors: ThemeColors = ThemeColors.current
  
  private init() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(updateColors),
      name: UIApplication.didBecomeActiveNotification,
      object: nil
    )
  }
  
  @objc private func updateColors() {
    colors = ThemeColors.current
  }
}

struct ThemeColors {
  let primaryText: Color
  let secondaryText: Color
  let tertiaryText: Color
  let primaryBackground: Color
  let secondaryBackground: Color
  let tertiaryBackground: Color
  let accent: Color
  var accentBackground: Color {
    accent.opacity(0.2)
  }
  var accentSecondaryBackground: Color {
    accent.opacity(0.1)
  }
  

  var accentStroke: Color {
    accentText.opacity(0.3)
  }
  let accentText: Color
  
  let red: Color
  let yellow: Color
  
  static var current: ThemeColors {
    UITraitCollection.current.userInterfaceStyle == .dark ? dark : light
  }
  
  static let light = ThemeColors(
    primaryText: Color(hex: "000000"),
    secondaryText: Color(hex: "666666"),
    tertiaryText: Color(hex: "999999"),
    primaryBackground: Color(hex: "FFFFFF"),
    secondaryBackground: Color(hex: "F5F5F5"),
    tertiaryBackground: Color(hex: "EEEEEE"),
    accent: Color(red: 0.7961, green: 0.949, blue: 0.9961),
    accentText: Color(red: 0.1961, green: 0.3333, blue: 0.3765).opacity(0.7),
    red: Color(hex: "#fed7cb"),
    yellow: .black
  )
  
  static let dark = ThemeColors(
    primaryText: Color(hex: "FFFFFF"),
    secondaryText: Color(hex: "CCCCCC"),
    tertiaryText: Color(hex: "999999"),
    primaryBackground: Color(hex: "000000"),
    secondaryBackground: Color(hex: "1C1C1E"),
    tertiaryBackground: Color(hex: "2C2C2E"),
    accent: Color(red: 0.1961, green: 0.3333, blue: 0.3765),
    accentText: Color(red: 0.1961, green: 0.3333, blue: 0.3765),
    red: Color(hex: "#fecbd9"),
    yellow: Color(hex: "#fef0cb")
  )
}

extension Color {
  init(hex: String) {
    let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int: UInt64 = 0
    Scanner(string: hex).scanHexInt64(&int)
    let a, r, g, b: UInt64
    switch hex.count {
    case 3:
      (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
    case 6:
      (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
    case 8:
      (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
    default:
      (a, r, g, b) = (255, 0, 0, 0)
    }
    self.init(
      .sRGB,
      red: Double(r) / 255,
      green: Double(g) / 255,
      blue: Double(b) / 255,
      opacity: Double(a) / 255
    )
  }
}

struct ThemeKey: EnvironmentKey {
  static let defaultValue = Theme.shared
}

extension EnvironmentValues {
  var theme: Theme {
    get { self[ThemeKey.self] }
    set { self[ThemeKey.self] = newValue }
  }
}
