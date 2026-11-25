//
//  CloudTheme.swift
//  InstaThought
//
//  The "Cloud" look: the app icon's outlined thought bubble, grown into the whole app.
//  Thick navy outlines instead of shadows, white fills on sky, and sun yellow for the next step.
//

import SwiftUI
import UIKit

enum Cloud {
  static let sky = Color(hex: "BDE8F7")
  static let white = Color.white
  static let night = Color(hex: "14284B")
  static let sun = Color(hex: "FFC94D")
  static let mist = Color(hex: "E4F5FC")
  /// Secondary text on white or sky.
  static let quiet = Color(hex: "3C5679")
  static let placeholder = Color(hex: "7F93AD")
  /// Outlines of disabled controls.
  static let soft = Color(hex: "9FB6C9")
  static let line: CGFloat = 2.5

  enum Weight: String {
    case regular = "Nunito-Regular", semibold = "Nunito-SemiBold", bold = "Nunito-Bold"
    case extraBold = "Nunito-ExtraBold", black = "Nunito-Black"
  }

  static func font(_ size: CGFloat, _ weight: Weight = .semibold) -> Font {
    .custom(weight.rawValue, size: size)
  }

  static func uiFont(_ size: CGFloat, _ weight: Weight = .semibold) -> UIFont {
    UIFont(name: weight.rawValue, size: size) ?? .systemFont(ofSize: size, weight: .semibold)
  }

  static func tap() {
    UIImpactFeedbackGenerator(style: .light).impactOccurred()
  }
}

// MARK: - Outlines

extension View {
  /// A white (or tinted) shape with the Cloud navy outline.
  func cloudOutlined(_ fill: Color = Cloud.white, radius: CGFloat, lineWidth: CGFloat = Cloud.line) -> some View {
    background(RoundedRectangle(cornerRadius: radius, style: .continuous).fill(fill))
      .overlay(RoundedRectangle(cornerRadius: radius, style: .continuous).strokeBorder(Cloud.night, lineWidth: lineWidth))
  }

  /// A solid navy edge underneath, so the shape looks like it's sitting on the page.
  func cloudEdge(radius: CGFloat, depth: CGFloat = 5) -> some View {
    background(RoundedRectangle(cornerRadius: radius, style: .continuous).fill(Cloud.night).offset(y: depth))
  }

  /// The standard top bar row.
  func cloudBar() -> some View {
    frame(maxWidth: .infinity).frame(height: 54).padding(.horizontal, 20)
  }
}

// MARK: - Buttons

/// The big pressable button. `.sun` is the next step; there is at most one per screen.
struct CloudButtonStyle: ButtonStyle {
  enum Kind { case sun, white }
  var kind: Kind = .sun
  var height: CGFloat = 56
  @Environment(\.isEnabled) private var isEnabled

  func makeBody(configuration: Configuration) -> some View {
    let pressed = configuration.isPressed && isEnabled
    return configuration.label
      .font(Cloud.font(18, .black))
      .labelStyle(CloudLabelStyle())
      .lineLimit(1)
      .minimumScaleFactor(0.8)
      .foregroundStyle(isEnabled ? Cloud.night : Cloud.placeholder)
      .padding(.horizontal, 16)
      .frame(maxWidth: .infinity)
      .frame(height: height)
      .background(Capsule().fill(isEnabled ? (kind == .sun ? Cloud.sun : Cloud.white) : Cloud.mist))
      .overlay(Capsule().strokeBorder(isEnabled ? Cloud.night : Cloud.soft, lineWidth: Cloud.line))
      .offset(y: pressed ? 3 : 0)
      .background(Capsule().fill(isEnabled ? Cloud.night : Cloud.soft).offset(y: 4))
      .animation(.easeOut(duration: 0.08), value: pressed)
  }
}

/// Small outlined pill for bar actions (Ideas, Done, Close, Preview).
struct CloudChipStyle: ButtonStyle {
  var fill: Color = Cloud.white
  var round = false

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(Cloud.font(15, .extraBold))
      .labelStyle(CloudLabelStyle(spacing: 6))
      .foregroundStyle(Cloud.night)
      .padding(.horizontal, round ? 0 : 15)
      .frame(minWidth: 40, minHeight: 40)
      .frame(width: round ? 40 : nil)
      .background(Capsule().fill(fill))
      .overlay(Capsule().strokeBorder(Cloud.night, lineWidth: Cloud.line))
      .scaleEffect(configuration.isPressed ? 0.94 : 1)
      .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
      .contentShape(Capsule())
  }
}

/// Selectable pill (tabs, fonts, shapes). Selected: mist fill and an outline.
struct CloudToggleStyle: ButtonStyle {
  var isOn: Bool
  var fill: Color = .clear
  var radius: CGFloat = 20

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .foregroundStyle(isOn ? Cloud.night : Cloud.quiet)
      .background(RoundedRectangle(cornerRadius: radius, style: .continuous).fill(isOn ? Cloud.mist : fill))
      .overlay(RoundedRectangle(cornerRadius: radius, style: .continuous)
        .strokeBorder(isOn ? Cloud.night : Color.clear, lineWidth: Cloud.line))
      .scaleEffect(configuration.isPressed ? 0.95 : 1)
      .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
      .contentShape(Rectangle())
  }
}

struct CloudLabelStyle: LabelStyle {
  var spacing: CGFloat = 8
  func makeBody(configuration: Configuration) -> some View {
    HStack(spacing: spacing) {
      configuration.icon.font(.system(size: 15, weight: .bold))
      configuration.title
    }
  }
}

struct CloudBackButton: View {
  let action: () -> Void
  var body: some View {
    Button {
      Cloud.tap()
      action()
    } label: {
      Image(systemName: "chevron.left").font(.system(size: 16, weight: .bold))
    }
    .buttonStyle(CloudChipStyle(round: true))
    .accessibilityLabel("Back")
  }
}

struct CloudWordmark: View {
  var body: some View {
    HStack(spacing: 8) {
      Image("icon_1024")
        .resizable()
        .frame(width: 34, height: 34)
        .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 9, style: .continuous).strokeBorder(Cloud.night, lineWidth: Cloud.line))
      Text("InstaThought")
        .font(Cloud.font(24, .black))
        .foregroundStyle(Cloud.night)
    }
    .accessibilityElement(children: .combine)
  }
}

// MARK: - Steppers

/// A labelled row with − value + buttons on a mist background.
struct CloudStepperRow: View {
  let label: String
  let value: String
  let onMinus: () -> Void
  let onPlus: () -> Void

  var body: some View {
    HStack {
      Text(label).font(Cloud.font(15, .extraBold))
      Spacer()
      HStack(spacing: 6) {
        roundButton("minus", label: "Decrease \(label)", action: onMinus)
        Text(value)
          .font(Cloud.font(16, .black))
          .monospacedDigit()
          .frame(minWidth: 44)
          .contentTransition(.numericText())
        roundButton("plus", label: "Increase \(label)", action: onPlus)
      }
    }
    .foregroundStyle(Cloud.night)
    .padding(.leading, 16)
    .padding(.trailing, 7)
    .padding(.vertical, 7)
    .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Cloud.mist))
  }

  private func roundButton(_ symbol: String, label: String, action: @escaping () -> Void) -> some View {
    Button {
      Cloud.tap()
      withAnimation(.snappy(duration: 0.15)) { action() }
    } label: {
      Image(systemName: symbol).font(.system(size: 15, weight: .heavy))
    }
    .buttonStyle(CloudChipStyle(round: true))
    .accessibilityLabel(label)
  }
}

enum CloudStep {
  /// Steps through a list of allowed values, or by 1 within a range.
  static func next(_ value: CGFloat, options: [CGFloat]? = nil, range: ClosedRange<CGFloat>? = nil, up: Bool) -> CGFloat {
    if let options {
      let index = options.firstIndex(of: value) ?? (options.lastIndex { $0 <= value } ?? 0)
      return options[min(max(index + (up ? 1 : -1), 0), options.count - 1)]
    }
    guard let range else { return value }
    return min(max(value + (up ? 1 : -1), range.lowerBound), range.upperBound)
  }

  static func format(_ value: CGFloat) -> String {
    value == value.rounded() ? String(format: "%.0f", value) : String(format: "%.1f", value)
  }
}

// MARK: - Feedback

/// The small "Saved" bubble that pops in at the top.
struct CloudToast: View {
  let text: String
  var body: some View {
    HStack(spacing: 10) {
      Image(systemName: "checkmark")
        .font(.system(size: 13, weight: .black))
        .frame(width: 30, height: 30)
        .background(Circle().fill(Cloud.sun))
        .overlay(Circle().strokeBorder(Cloud.night, lineWidth: Cloud.line))
      Text(text).font(Cloud.font(17, .black))
    }
    .foregroundStyle(Cloud.night)
    .padding(.leading, 12)
    .padding(.trailing, 20)
    .padding(.vertical, 10)
    .cloudOutlined(radius: 30)
    .accessibilityElement(children: .combine)
  }
}

/// A message bubble with one or two actions, used instead of a system alert.
struct CloudAlert: View {
  let title: String
  let message: String
  let primary: (String, () -> Void)
  var secondary: (String, () -> Void)? = nil

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text(title).font(Cloud.font(22, .black))
      Text(message)
        .font(Cloud.font(16, .semibold))
        .foregroundStyle(Cloud.quiet)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.bottom, 12)
      HStack(spacing: 10) {
        if let secondary {
          Button(secondary.0) { Cloud.tap(); secondary.1() }
            .buttonStyle(CloudButtonStyle(kind: .white, height: 52))
            .frame(width: 124)
        }
        Button(primary.0) { Cloud.tap(); primary.1() }
          .buttonStyle(CloudButtonStyle(height: 52))
      }
    }
    .foregroundStyle(Cloud.night)
    .padding(.horizontal, 22)
    .padding(.top, 22)
    .padding(.bottom, 24)
    .cloudOutlined(radius: 36, lineWidth: 3)
    .padding(.horizontal, 18)
  }
}

// MARK: - Shapes

/// The top edge of a bottom sheet: rounded corners, outline along the top and down the sides.
struct TopRoundedEdge: SwiftUI.Shape {
  var radius: CGFloat = 34
  func path(in rect: CGRect) -> Path {
    var p = Path()
    p.move(to: CGPoint(x: rect.minX, y: rect.maxY))
    p.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
    p.addQuadCurve(to: CGPoint(x: rect.minX + radius, y: rect.minY), control: CGPoint(x: rect.minX, y: rect.minY))
    p.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
    p.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + radius), control: CGPoint(x: rect.maxX, y: rect.minY))
    p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
    return p
  }
}

// MARK: - Fonts offered on the Style screen

enum PageFonts {
  /// The faces used by the bundled presets, in preset order, without repeats.
  static let bundled: [String] = {
    var seen = Set<String>()
    return Style.defaultStyles.map(\.fontName).filter { seen.insert($0).inserted }
  }()

  static func displayName(_ fontName: String) -> String {
    let base = fontName
      .replacingOccurrences(of: "-Roman_Regular", with: "")
      .replacingOccurrences(of: "Roman-Regular", with: "")
      .replacingOccurrences(of: "-Regular", with: "")
      .replacingOccurrences(of: "-Medium", with: "")
      .replacingOccurrences(of: "_Regular", with: "")
    // "LibreBaskerville" -> "Libre Baskerville"; leave digits attached ("SourceSans3").
    var out = ""
    for (i, ch) in base.enumerated() {
      if i > 0, ch.isUppercase, let prev = out.last, prev.isLowercase { out.append(" ") }
      out.append(ch)
    }
    return out
  }
}

// MARK: - Swipe back with a hidden navigation bar

extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
  override open func viewDidLoad() {
    super.viewDidLoad()
    interactivePopGestureRecognizer?.delegate = self
  }

  public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    viewControllers.count > 1
  }
}
