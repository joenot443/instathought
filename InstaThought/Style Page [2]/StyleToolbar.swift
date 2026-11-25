import SwiftUI

enum StylePanel: String, CaseIterable {
  case typography
  case colors
  case layout
  case styles

  var label: String {
    switch self {
    case .typography: return "Font"
    case .colors: return "Color"
    case .layout: return "Layout"
    case .styles: return "Presets"
    }
  }
}

/// The white sheet under the page preview: tabs, then the controls for the chosen tab.
struct StyleToolbar: View {
  @ObservedObject var viewModel: InstaThoughtViewModel
  @Binding var activePanel: StylePanel

  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 6) {
        ForEach(StylePanel.allCases, id: \.self) { panel in
          Button {
            Cloud.tap()
            withAnimation(.snappy(duration: 0.2)) { activePanel = panel }
          } label: {
            Text(panel.label)
              .font(Cloud.font(14, .extraBold))
              .frame(maxWidth: .infinity)
              .padding(.vertical, 9)
          }
          .buttonStyle(CloudToggleStyle(isOn: activePanel == panel))
          .accessibilityAddTraits(activePanel == panel ? .isSelected : [])
        }
      }
      .padding(.horizontal, 18)
      .padding(.top, 16)
      .padding(.bottom, 14)

      Group {
        switch activePanel {
        case .typography: TypographyPanel(viewModel: viewModel)
        case .colors: ColorsPanel(viewModel: viewModel)
        case .layout: LayoutPanel(viewModel: viewModel)
        case .styles: StylesPanel(viewModel: viewModel)
        }
      }
      .frame(height: 226, alignment: .top)
      .padding(.bottom, 6)
    }
    .foregroundStyle(Cloud.night)
    .background(TopRoundedEdge().fill(Cloud.white).ignoresSafeArea(edges: .bottom))
    .overlay(TopRoundedEdge().stroke(Cloud.night, lineWidth: Cloud.line).ignoresSafeArea(edges: .bottom))
  }
}

// MARK: - Font

struct TypographyPanel: View {
  @ObservedObject var viewModel: InstaThoughtViewModel

  /// The current face first, then the faces the presets use.
  private var faces: [String] {
    let current = viewModel.style.fontName
    return [current] + PageFonts.bundled.filter { $0 != current }
  }

  var body: some View {
    VStack(spacing: 8) {
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 8) {
          ForEach(faces, id: \.self) { face in
            Button {
              Cloud.tap()
              viewModel.style.fontName = face
            } label: {
              Text(PageFonts.displayName(face))
                .font(.custom(face, size: 19))
                .lineLimit(1)
                .padding(.horizontal, 16)
                .frame(height: 46)
            }
            .buttonStyle(CloudToggleStyle(isOn: viewModel.style.fontName == face, fill: Cloud.white, radius: 23))
            .overlay(Capsule().strokeBorder(Color(hex: "C9DCE6"), lineWidth: 2).opacity(viewModel.style.fontName == face ? 0 : 1))
          }
          Button {
            Cloud.tap()
            viewModel.isFontPickerActive = true
          } label: {
            Label("All fonts", systemImage: "textformat")
          }
          .buttonStyle(CloudChipStyle())
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 2)
      }

      VStack(spacing: 8) {
        CloudStepperRow(label: "Size", value: CloudStep.format(viewModel.style.fontSize),
          onMinus: { viewModel.style.fontSize = CloudStep.next(viewModel.style.fontSize, range: 8...100, up: false) },
          onPlus: { viewModel.style.fontSize = CloudStep.next(viewModel.style.fontSize, range: 8...100, up: true) })
        CloudStepperRow(label: "Line spacing", value: CloudStep.format(viewModel.style.lineHeight),
          onMinus: { viewModel.style.lineHeight = CloudStep.next(viewModel.style.lineHeight, options: Style.defaultLineHeights, up: false) },
          onPlus: { viewModel.style.lineHeight = CloudStep.next(viewModel.style.lineHeight, options: Style.defaultLineHeights, up: true) })
        AlignmentRow(selection: $viewModel.style.textAlignment)
      }
      .padding(.horizontal, 18)
    }
  }
}

struct AlignmentRow: View {
  @Binding var selection: TextAlignmentOption

  var body: some View {
    HStack {
      Text("Align").font(Cloud.font(15, .extraBold))
      Spacer()
      HStack(spacing: 4) {
        ForEach(TextAlignmentOption.allCases, id: \.self) { option in
          Button {
            Cloud.tap()
            selection = option
          } label: {
            option.icon()
              .font(.system(size: 15, weight: .bold))
              .frame(width: 40, height: 40)
          }
          .buttonStyle(CloudToggleStyle(isOn: selection == option, fill: .clear, radius: 20))
          .accessibilityLabel(option.name())
          .accessibilityAddTraits(selection == option ? .isSelected : [])
        }
      }
    }
    .padding(.leading, 16)
    .padding(.trailing, 7)
    .padding(.vertical, 5)
    .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Cloud.mist))
  }
}

// MARK: - Color

struct ColorsPanel: View {
  @ObservedObject var viewModel: InstaThoughtViewModel

  var body: some View {
    VStack(spacing: 8) {
      ColorRow(label: "Text", color: viewModel.style.foregroundColor, isPresented: $viewModel.isColorPickerActive) { color in
        viewModel.style.foregroundColor = color
      }
      ColorRow(label: "Background", color: viewModel.style.backgroundColor, isPresented: $viewModel.isBackgroundColorPickerActive) { color in
        viewModel.style.backgroundColor = color
      }
    }
    .padding(.horizontal, 18)
  }
}

struct ColorRow: View {
  let label: String
  let color: Color
  @Binding var isPresented: Bool
  let onColorSelected: (Color) -> Void

  var body: some View {
    Button {
      Cloud.tap()
      isPresented = true
    } label: {
      HStack {
        Text(label).font(Cloud.font(15, .extraBold))
        Spacer()
        Circle()
          .fill(color)
          .frame(width: 38, height: 38)
          .overlay(Circle().strokeBorder(Cloud.night, lineWidth: Cloud.line))
        Image(systemName: "chevron.right")
          .font(.system(size: 13, weight: .bold))
          .foregroundStyle(Cloud.quiet)
          .padding(.horizontal, 6)
      }
      .foregroundStyle(Cloud.night)
      .padding(.leading, 16)
      .padding(.trailing, 8)
      .padding(.vertical, 8)
      .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Cloud.mist))
      .contentShape(Rectangle())
    }
    .buttonStyle(TemplateCardButtonStyle())
    .accessibilityLabel("\(label) color")
    .popover(isPresented: $isPresented) {
      ColorPickerView(onColorSelected: onColorSelected)
        .presentationCompactAdaptation(.sheet)
        .presentationDetents([.fraction(0.35)])
    }
  }
}

// MARK: - Layout

struct LayoutPanel: View {
  @ObservedObject var viewModel: InstaThoughtViewModel

  var body: some View {
    VStack(spacing: 8) {
      HStack(spacing: 8) {
        ForEach(Shape.allCases, id: \.self) { shape in
          Button {
            Cloud.tap()
            viewModel.style.shape = shape
          } label: {
            VStack(spacing: 4) {
              Image(systemName: shape.icon()).font(.system(size: 18, weight: .semibold))
              Text(shape.name()).font(Cloud.font(13, .extraBold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 62)
          }
          .buttonStyle(CloudToggleStyle(isOn: viewModel.style.shape == shape, fill: Cloud.mist, radius: 22))
          .accessibilityAddTraits(viewModel.style.shape == shape ? .isSelected : [])
        }
      }
      CloudStepperRow(label: "Top and bottom margin", value: CloudStep.format(viewModel.style.verticalPadding),
        onMinus: { viewModel.style.verticalPadding = CloudStep.next(viewModel.style.verticalPadding, options: Style.defaultPaddings, up: false) },
        onPlus: { viewModel.style.verticalPadding = CloudStep.next(viewModel.style.verticalPadding, options: Style.defaultPaddings, up: true) })
      CloudStepperRow(label: "Side margin", value: CloudStep.format(viewModel.style.padding),
        onMinus: { viewModel.style.padding = CloudStep.next(viewModel.style.padding, options: Style.defaultPaddings, up: false) },
        onPlus: { viewModel.style.padding = CloudStep.next(viewModel.style.padding, options: Style.defaultPaddings, up: true) })
    }
    .padding(.horizontal, 18)
  }
}

// MARK: - Presets

struct StylesPanel: View {
  @ObservedObject var viewModel: InstaThoughtViewModel

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      ScrollView(.horizontal, showsIndicators: false) {
        LazyHStack(spacing: 12) {
          ForEach(Style.defaultStyles.indices, id: \.self) { index in
            let preset = Style.defaultStyles[index]
            PresetThumbnail(text: viewModel.text, style: preset, isSelected: preset === viewModel.style, ring: Cloud.night) {
              Cloud.tap()
              viewModel.apply(preset: preset)
            }
            .frame(width: 92, height: 115)
          }
        }
        .padding(.horizontal, 18)
        .padding(.top, 4)
        .padding(.bottom, 8)
      }
      .frame(height: 132)

      Button {
        Cloud.tap()
        viewModel.isStylePickerActive = true
      } label: {
        Label("See all \(Style.defaultStyles.count) presets", systemImage: "square.grid.3x3")
      }
      .buttonStyle(CloudChipStyle())
      .padding(.horizontal, 18)
    }
  }
}

/// A preset rendered with your own text, outlined, with a ring when it's the one in use.
struct PresetThumbnail: View {
  let text: String
  let style: Style
  let isSelected: Bool
  var ring: Color = Cloud.sun
  let onTap: () -> Void

  var body: some View {
    RenderViewWrapper(text: text, style: thumbnailStyle, onTap: onTap)
      .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
      .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).strokeBorder(Cloud.night, lineWidth: Cloud.line))
      .cloudEdge(radius: 12, depth: 4)
      .padding(3)
      .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).strokeBorder(ring, lineWidth: 4).opacity(isSelected ? 1 : 0))
      .accessibilityElement()
      .accessibilityLabel("Preset")
      .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
  }

  /// Small enough that words don't break across lines in a narrow portrait tile.
  private var thumbnailStyle: Style {
    Style(foregroundColor: style.foregroundColor, backgroundColor: style.backgroundColor, fontSize: 9.5,
          padding: 9, verticalPadding: 10, lineHeight: 1.2, fontName: style.fontName, shape: .fullscreen)
  }
}

struct StepperButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
      .opacity(configuration.isPressed ? 0.7 : 1.0)
      .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
  }
}
