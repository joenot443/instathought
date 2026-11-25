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
      CloudSegmented(options: StylePanel.allCases, selection: $activePanel, height: 36,
                     accessibilityLabel: { $0.label }) { panel, _ in
        Text(panel.label).font(Cloud.font(15, .extraBold))
      }
      .padding(.horizontal, 18)
      .padding(.top, 18)
      .padding(.bottom, 14)

      Group {
        switch activePanel {
        case .typography: TypographyPanel(viewModel: viewModel)
        case .colors: ColorsPanel(viewModel: viewModel)
        case .layout: LayoutPanel(viewModel: viewModel)
        case .styles: StylesPanel(viewModel: viewModel)
        }
      }
      .frame(height: 236, alignment: .top)
      .padding(.bottom, 6)
    }
    .foregroundStyle(Cloud.night)
    .background(TopRoundedEdge().fill(Cloud.white).ignoresSafeArea(edges: .bottom))
    .overlay(TopRoundedEdge().stroke(Cloud.stroke, lineWidth: Cloud.line).ignoresSafeArea(edges: .bottom))
  }
}

// MARK: - Font

struct TypographyPanel: View {
  @ObservedObject var viewModel: InstaThoughtViewModel

  var body: some View {
    VStack(spacing: 8) {
      let face = FontCatalog.face(viewModel.style.fontName)
      CloudPickerRow(label: "Font", action: { viewModel.isFontPickerActive = true }) {
        Text(face.name)
          .font(.custom(face.id, size: 19))
          .lineLimit(1)
      }
      .accessibilityLabel("Choose font")
      .accessibilityValue(face.name)

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

struct AlignmentRow: View {
  @Binding var selection: TextAlignmentOption

  var body: some View {
    HStack {
      Text("Align").font(Cloud.font(15, .extraBold))
      Spacer()
      CloudSegmented(options: TextAlignmentOption.allCases, selection: $selection, height: 32,
                     accessibilityLabel: { $0.name() }) { option, _ in
        option.icon().font(.system(size: 14, weight: .bold))
      }
      .frame(width: 184)
    }
    .foregroundStyle(Cloud.night)
    .padding(.leading, 16)
    .padding(.trailing, 6)
    .frame(height: 52)
    .cloudRecessed(RoundedRectangle(cornerRadius: 20, style: .continuous))
  }
}

// MARK: - Color

struct ColorsPanel: View {
  @ObservedObject var viewModel: InstaThoughtViewModel

  var body: some View {
    VStack(spacing: 8) {
      ColorRow(label: "Text", color: viewModel.style.foregroundColor, isPresented: $viewModel.isColorPickerActive)
      ColorRow(label: "Background", color: viewModel.style.backgroundColor, isPresented: $viewModel.isBackgroundColorPickerActive)
    }
    .padding(.horizontal, 18)
  }
}

struct ColorRow: View {
  let label: String
  let color: Color
  @Binding var isPresented: Bool

  var body: some View {
    CloudPickerRow(label: label, action: { isPresented = true }) {
      Circle()
        .fill(color)
        .frame(width: 30, height: 30)
        .overlay(Circle().strokeBorder(Cloud.stroke, lineWidth: Cloud.controlLine))
        .padding(3)
        .background(Circle().fill(Cloud.thumb))
    }
    .accessibilityLabel("\(label) color")
  }
}

// MARK: - Layout

struct LayoutPanel: View {
  @ObservedObject var viewModel: InstaThoughtViewModel

  var body: some View {
    VStack(spacing: 8) {
      CloudSegmented(options: Shape.allCases, selection: $viewModel.style.shape, height: 56, radius: 22,
                     accessibilityLabel: { $0.name() }) { shape, _ in
        VStack(spacing: 3) {
          Image(systemName: shape.icon()).font(.system(size: 17, weight: .semibold))
          Text(shape.name()).font(Cloud.font(13, .extraBold))
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
            PresetThumbnail(text: viewModel.text, style: preset, isSelected: preset === viewModel.style) {
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
    // A real SwiftUI button: the rendered page underneath is display-only, so the outline
    // and ring overlays can't swallow the tap.
    Button(action: onTap) {
      RenderViewWrapper(text: text, style: thumbnailStyle, onTap: {})
        .allowsHitTesting(false)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).strokeBorder(Cloud.stroke, lineWidth: Cloud.controlLine))
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Cloud.edge).offset(y: 3))
        .padding(4)
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(ring, lineWidth: 3.5).opacity(isSelected ? 1 : 0))
        .contentShape(Rectangle())
    }
    .buttonStyle(TemplateCardButtonStyle())
    .accessibilityLabel("Preset")
    .accessibilityAddTraits(isSelected ? .isSelected : [])
  }

  /// Small enough that words don't break across lines in a narrow portrait tile.
  private var thumbnailStyle: Style {
    Style(foregroundColor: style.foregroundColor, backgroundColor: style.backgroundColor, fontSize: 9.5,
          padding: 9, verticalPadding: 10, lineHeight: 1.2, fontName: style.fontName, shape: .fullscreen)
  }
}
