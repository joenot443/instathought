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
  // Each token is (light, dark). Dark mode is a night sky: deep navy behind,
  // lighter navy surfaces, and near-white ink and outlines where light mode uses navy.

  /// Screen background.
  static let sky = dynamic("BDE8F7", "0C1A33")
  /// Surfaces: the bubble, cards, sheets, white buttons.
  static let white = dynamic("FFFFFF", "1A3159")
  /// Ink: text, outlines and the solid edge under shapes.
  static let night = dynamic("14284B", "EAF4FB")
  /// The next step. The same yellow in both modes; text on it is always `onSun`.
  static let sun = Color(hex: "FFC94D")
  static let onSun = Color(hex: "14284B")
  /// Quiet fills: stepper rows, selected tabs.
  static let mist = dynamic("E4F5FC", "243F6D")
  /// Secondary text on surfaces or sky.
  static let quiet = dynamic("3C5679", "AFC6DD")
  static let placeholder = dynamic("7F93AD", "7D95B7")
  /// Outlines of disabled controls and inactive dots.
  static let soft = dynamic("9FB6C9", "4B6894")
  /// Unselected chip outline.
  static let faint = dynamic("C9DCE6", "3A5683")
  static let line: CGFloat = 2.5

  // Controls. Everything you can press is raised: a surface, a `stroke` outline and a solid
  // `edge` underneath that it sinks onto when pressed. Everything you choose from sits in a
  // recessed `track`, and the chosen option is a raised `thumb` inside it.

  /// Outline of controls. Softer than `night` in dark mode, where pure white outlines glare.
  static let stroke = dynamic("14284B", "93ADD3")
  /// The solid edge under raised controls: navy by day, a deep shadow by night.
  static let edge = dynamic("14284B", "050C1C")
  /// Recessed wells: segmented tracks, stepper rows, the search field.
  static let track = dynamic("DFF1F8", "102449")
  /// The raised selection inside a track.
  static let thumb = dynamic("FFFFFF", "2C4C82")
  /// Fills while pressed.
  static let sunPressed = Color(hex: "F4BA34")
  static let whitePressed = dynamic("EEF8FC", "223F6E")
  static let controlLine: CGFloat = 2
  /// Sun as an ink, for small marks like a filled star on white: deeper by day so it reads.
  static let sunInk = dynamic("E3A008", "FFC94D")

  /// UIKit version of `night`, for the text view.
  static let uiNight = dynamicUI("14284B", "EAF4FB")
  /// UIKit version of `quiet`, for the editor's page-break divider.
  static let uiQuiet = dynamicUI("3C5679", "AFC6DD")

  private static func dynamicUI(_ light: String, _ dark: String) -> UIColor {
    let l = UIColor(Color(hex: light)), d = UIColor(Color(hex: dark))
    return UIColor { $0.userInterfaceStyle == .dark ? d : l }
  }

  private static func dynamic(_ light: String, _ dark: String) -> Color {
    Color(uiColor: dynamicUI(light, dark))
  }

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

  /// The lighter click for moving between options.
  static func tick() {
    UISelectionFeedbackGenerator().selectionChanged()
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

private struct CloudForcePressedKey: EnvironmentKey { static let defaultValue = false }

extension EnvironmentValues {
  /// Draws Cloud buttons in their pressed state, for the control gallery screenshots.
  var cloudForcePressed: Bool {
    get { self[CloudForcePressedKey.self] }
    set { self[CloudForcePressedKey.self] = newValue }
  }
}

/// A raised surface: fill, outline, and a solid edge `depth` points deep. Pressed, it sinks onto the edge.
struct CloudRaised<S: InsettableShape>: ViewModifier {
  let shape: S
  var fill: Color
  var stroke: Color = Cloud.stroke
  var lineWidth: CGFloat = Cloud.controlLine
  var depth: CGFloat = 3
  var pressed = false

  func body(content: Content) -> some View {
    content
      .background(shape.fill(fill))
      .overlay(shape.strokeBorder(stroke, lineWidth: lineWidth))
      .offset(y: pressed ? depth : 0)
      .background(shape.fill(Cloud.edge).offset(y: depth))
      .animation(.easeOut(duration: pressed ? 0.05 : 0.12), value: pressed)
  }
}

/// A recessed well with a hard inner shadow along its top edge.
struct CloudRecessed<S: SwiftUI.Shape>: ViewModifier {
  let shape: S
  func body(content: Content) -> some View {
    content.background(shape.fill(Cloud.track.shadow(.inner(color: Cloud.edge.opacity(0.16), radius: 0, x: 0, y: 2))))
  }
}

extension View {
  func cloudRaised<S: InsettableShape>(_ shape: S, fill: Color = Cloud.white, depth: CGFloat = 3, lineWidth: CGFloat = Cloud.controlLine, pressed: Bool = false) -> some View {
    modifier(CloudRaised(shape: shape, fill: fill, lineWidth: lineWidth, depth: depth, pressed: pressed))
  }

  func cloudRecessed<S: SwiftUI.Shape>(_ shape: S) -> some View {
    modifier(CloudRecessed(shape: shape))
  }
}

/// The big button. `.sun` is the next step; there is at most one per screen.
struct CloudButtonStyle: ButtonStyle {
  enum Kind { case sun, white }
  var kind: Kind = .sun
  var height: CGFloat = 56
  @Environment(\.isEnabled) private var isEnabled
  @Environment(\.cloudForcePressed) private var forcePressed

  func makeBody(configuration: Configuration) -> some View {
    let pressed = (configuration.isPressed || forcePressed) && isEnabled
    let fill: Color = kind == .sun ? (pressed ? Cloud.sunPressed : Cloud.sun) : (pressed ? Cloud.whitePressed : Cloud.white)
    return configuration.label
      .font(Cloud.font(17, .black))
      .labelStyle(CloudLabelStyle(iconSize: 16, spacing: 8))
      .lineLimit(1)
      .minimumScaleFactor(0.8)
      .foregroundStyle(isEnabled ? (kind == .sun ? Cloud.onSun : Cloud.night) : Cloud.placeholder)
      .padding(.horizontal, 18)
      .frame(maxWidth: .infinity)
      .frame(height: height)
      .contentShape(Capsule())
      .modifier(CloudRaised(shape: Capsule(),
                            fill: isEnabled ? fill : Cloud.track,
                            stroke: isEnabled ? Cloud.stroke : Cloud.soft,
                            lineWidth: isEnabled ? Cloud.line : Cloud.controlLine,
                            depth: isEnabled ? 4 : 0,
                            pressed: pressed))
  }
}

/// Small raised pill for bar actions (Ideas, Done, Preview) and secondary actions.
struct CloudChipStyle: ButtonStyle {
  var fill: Color = Cloud.white
  /// Text colour; pass `Cloud.onSun` when the fill is `Cloud.sun`.
  var ink: Color = Cloud.night
  var round = false
  var size: CGFloat = 38
  @Environment(\.cloudForcePressed) private var forcePressed

  func makeBody(configuration: Configuration) -> some View {
    let pressed = configuration.isPressed || forcePressed
    let pressedFill = fill == Cloud.sun ? Cloud.sunPressed : Cloud.whitePressed
    return configuration.label
      .font(Cloud.font(15, .extraBold))
      .labelStyle(CloudLabelStyle(iconSize: 13, spacing: 6))
      .foregroundStyle(ink)
      .padding(.horizontal, round ? 0 : 14)
      .frame(minWidth: size, minHeight: size)
      .frame(width: round ? size : nil, height: size)
      .contentShape(Capsule())
      .cloudRaised(Capsule(), fill: pressed ? pressedFill : fill, depth: 3, pressed: pressed)
      .padding(.bottom, 3)
  }
}

/// A row of options in a recessed track; the chosen one is a raised thumb that slides between them.
struct CloudSegmented<Option: Hashable, Content: View>: View {
  let options: [Option]
  @Binding var selection: Option
  var height: CGFloat = 38
  var radius: CGFloat? = nil
  var accessibilityLabel: (Option) -> String
  @ViewBuilder var content: (Option, Bool) -> Content
  @Namespace private var thumb

  var body: some View {
    let outer = radius ?? height / 2 + 4
    HStack(spacing: 0) {
      ForEach(options, id: \.self) { option in
        let isOn = option == selection
        Button {
          guard !isOn else { return }
          Cloud.tick()
          withAnimation(.spring(response: 0.3, dampingFraction: 0.78)) { selection = option }
        } label: {
          content(option, isOn)
            .foregroundStyle(isOn ? Cloud.night : Cloud.quiet)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background {
              if isOn {
                RoundedRectangle(cornerRadius: outer - 4, style: .continuous)
                  .fill(Cloud.thumb)
                  .overlay(RoundedRectangle(cornerRadius: outer - 4, style: .continuous).strokeBorder(Cloud.stroke, lineWidth: Cloud.controlLine))
                  .background(RoundedRectangle(cornerRadius: outer - 4, style: .continuous).fill(Cloud.edge).offset(y: 2))
                  .matchedGeometryEffect(id: "thumb", in: thumb)
              }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(SegmentPressStyle())
        .accessibilityLabel(accessibilityLabel(option))
        .accessibilityAddTraits(isOn ? .isSelected : [])
      }
    }
    .padding(4)
    .padding(.bottom, 2)
    .cloudRecessed(RoundedRectangle(cornerRadius: outer, style: .continuous))
  }
}

/// Unchosen segments dip slightly under the finger.
private struct SegmentPressStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaleEffect(configuration.isPressed ? 0.96 : 1)
      .opacity(configuration.isPressed ? 0.8 : 1)
      .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
  }
}

/// A recessed row that opens a chooser: label on the left, the current value and a chevron on the right.
struct CloudPickerRow<Value: View>: View {
  let label: String
  let action: () -> Void
  @ViewBuilder var value: () -> Value

  var body: some View {
    Button {
      Cloud.tap()
      action()
    } label: {
      HStack(spacing: 10) {
        Text(label).font(Cloud.font(15, .extraBold))
        Spacer(minLength: 8)
        value()
        Image(systemName: "chevron.right")
          .font(.system(size: 12, weight: .bold))
          .foregroundStyle(Cloud.quiet)
      }
      .foregroundStyle(Cloud.night)
      .padding(.leading, 16)
      .padding(.trailing, 14)
      .frame(height: 52)
      .contentShape(Rectangle())
    }
    .buttonStyle(RowPressStyle())
    .cloudRecessed(RoundedRectangle(cornerRadius: 20, style: .continuous))
  }
}

/// Rows darken a touch while pressed rather than moving.
struct RowPressStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Cloud.edge.opacity(configuration.isPressed ? 0.06 : 0)))
      .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
  }
}

struct CloudLabelStyle: LabelStyle {
  var iconSize: CGFloat = 15
  var spacing: CGFloat = 8
  func makeBody(configuration: Configuration) -> some View {
    HStack(spacing: spacing) {
      configuration.icon.font(.system(size: iconSize, weight: .bold))
      configuration.title
    }
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

/// A labelled recessed row with raised − and + buttons either side of the value.
struct CloudStepperRow: View {
  let label: String
  let value: String
  let onMinus: () -> Void
  let onPlus: () -> Void

  var body: some View {
    HStack {
      Text(label).font(Cloud.font(15, .extraBold))
      Spacer()
      HStack(spacing: 4) {
        roundButton("minus", label: "Decrease \(label)", action: onMinus)
        Text(value)
          .font(Cloud.font(16, .black))
          .monospacedDigit()
          .frame(minWidth: 46)
          .contentTransition(.numericText())
        roundButton("plus", label: "Increase \(label)", action: onPlus)
      }
    }
    .foregroundStyle(Cloud.night)
    .padding(.leading, 16)
    .padding(.trailing, 8)
    .frame(height: 52)
    .cloudRecessed(RoundedRectangle(cornerRadius: 20, style: .continuous))
  }

  private func roundButton(_ symbol: String, label: String, action: @escaping () -> Void) -> some View {
    Button {
      Cloud.tap()
      withAnimation(.snappy(duration: 0.15)) { action() }
    } label: {
      Image(systemName: symbol).font(.system(size: 13, weight: .black))
    }
    .buttonStyle(CloudChipStyle(round: true, size: 34))
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
        .foregroundStyle(Cloud.onSun)
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

// MARK: - Navigation bar items

/// A navigation bar item drawn in Cloud style. On iOS 26 and later the bar would otherwise
/// wrap it in a glass capsule; this turns that off so the Cloud outline shows instead.
struct CloudBarItem<Content: View>: ToolbarContent {
  var placement: ToolbarItemPlacement = .topBarTrailing
  @ViewBuilder var content: () -> Content

  var body: some ToolbarContent {
    if #available(iOS 26.0, *) {
      ToolbarItem(placement: placement, content: content).sharedBackgroundVisibility(.hidden)
    } else {
      ToolbarItem(placement: placement, content: content)
    }
  }
}

extension View {
  /// Pushed screens keep the system navigation bar, so Back and the edge swipe behave natively,
  /// but with no background or title so the sky shows through.
  func cloudNavigationBar() -> some View {
    navigationTitle("")
      .navigationBarTitleDisplayMode(.inline)
      .toolbarBackground(.hidden, for: .navigationBar)
  }
}
