import Foundation
import UIKit
import FontPicker
import SwiftUI

struct StyleControlView: View {
  @ObservedObject var viewModel: InstaThoughtViewModel

  @State private var typographyExpanded = true
  @State private var colorsExpanded = true
  @State private var layoutExpanded = true
  @State private var stylesExpanded = false

  var body: some View {
    ScrollView {
      VStack(spacing: 12) {
        // Typography Section
        AccordionSection(
          title: "Typography",
          icon: "textformat",
          iconColor: .blue,
          isExpanded: $typographyExpanded
        ) {
          VStack(spacing: 8) {
            HStack {
              ActionButton(icon: "textformat.size", label: viewModel.style.fontName) {
                viewModel.isFontPickerActive = true
              }
            }

            HStack {
              AdjusterView(
                icon: "textformat.size",
                value: $viewModel.style.fontSize,
                mode: .continuous(range: 1...100)
              )

              ActionButton(icon: viewModel.style.textAlignment.icon(), label: viewModel.style.textAlignment.name(), action: {
                viewModel.style.textAlignment.advance()
              })

              AdjusterView(
                icon: "arrow.up.and.down.text.horizontal",
                value: $viewModel.style.lineHeight,
                mode: .stepped(options: Style.defaultLineHeights)
              )
            }
          }
        }

        // Colors Section
        AccordionSection(
          title: "Colors",
          icon: "paintpalette.fill",
          iconColor: .purple,
          isExpanded: $colorsExpanded
        ) {
          HStack(spacing: 12) {
            ColorSwatchButton(
              label: "Text",
              color: viewModel.style.foregroundColor,
              isPresented: $viewModel.isColorPickerActive
            ) { color in
              viewModel.style.foregroundColor = color
            }

            ColorSwatchButton(
              label: "Background",
              color: viewModel.style.backgroundColor,
              isPresented: $viewModel.isBackgroundColorPickerActive
            ) { color in
              viewModel.style.backgroundColor = color
            }
          }
        }

        // Layout Section
        AccordionSection(
          title: "Layout",
          icon: "rectangle.3.group",
          iconColor: .orange,
          isExpanded: $layoutExpanded
        ) {
          HStack {
            ActionButton(icon: viewModel.style.shape.icon(), label: viewModel.style.shape.name()) {
              viewModel.style.shape.advance()
            }

            AdjusterView(
              icon: "rectangle.compress.vertical",
              value: $viewModel.style.verticalPadding,
              mode: .stepped(options: Style.defaultPaddings)
            )

            AdjusterView(
              icon: "rectangle.compress.vertical",
              value: $viewModel.style.padding,
              mode: .stepped(options: Style.defaultPaddings),
              rotation: 90.0
            )
          }
        }

        // Styles Section
        AccordionSection(
          title: "Styles",
          icon: "sparkles",
          iconColor: .pink,
          isExpanded: $stylesExpanded
        ) {
          ActionButton(icon: "paintpalette.fill", label: "Browse Styles") {
            viewModel.isStylePickerActive = true
          }
        }
      }
      .padding(.horizontal)
      .padding(.top, 4)
      .padding(.bottom, 20)
    }
    .sheet(isPresented: $viewModel.isStylePickerActive) {
      StyleBrowserView(styles: Style.defaultStyles, text: viewModel.text, onStyleSelected: { style in
        viewModel.style = style
        viewModel.registerBindings()
        viewModel.requestPreviewRender()
      })
    }
  }
}

// MARK: - Color Swatch Button

struct ColorSwatchButton: View {
  let label: String
  let color: Color
  @Binding var isPresented: Bool
  let onColorSelected: (Color) -> Void

  @State private var buttonScale: CGFloat = 1.0

  var body: some View {
    HStack(spacing: 10) {
      // Color swatch with shadow
      RoundedRectangle(cornerRadius: 8)
        .fill(color)
        .frame(width: 32, height: 32)
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(Color.black.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: color.opacity(0.3), radius: 4, y: 2)

      VStack(alignment: .leading, spacing: 1) {
        Text(label)
          .font(.subheadline)
          .fontWeight(.medium)
          .foregroundStyle(Theme.shared.colors.primaryText)

        Text(color.hexString ?? "Custom")
          .font(.caption2)
          .foregroundStyle(Theme.shared.colors.tertiaryText)
          .textCase(.uppercase)
      }

      Spacer()

      Image(systemName: "chevron.right")
        .font(.system(size: 10, weight: .bold))
        .foregroundStyle(Theme.shared.colors.tertiaryText)
    }
    .padding(10)
    .frame(maxWidth: .infinity)
    .background(Color.white)
    .cornerRadius(10)
    .shadow(color: .black.opacity(0.04), radius: 4, y: 1)
    .scaleEffect(buttonScale)
    .animation(.spring(response: 0.2, dampingFraction: 0.6), value: buttonScale)
    .pressEvents {
      withAnimation { buttonScale = 0.97 }
    } onRelease: {
      withAnimation { buttonScale = 1.0 }
      isPresented = true
    }
    .popover(isPresented: $isPresented) {
      ColorPickerView(onColorSelected: { selectedColor in
        onColorSelected(selectedColor)
      })
      .presentationBackgroundInteraction(.enabled)
      .presentationCompactAdaptation(.sheet)
      .presentationDetents([.fraction(0.3)])
    }
  }
}

// MARK: - Color Hex Extension

extension Color {
  var hexString: String? {
    guard let components = UIColor(self).cgColor.components else { return nil }
    let r = Int(components[0] * 255)
    let g = Int(components.count > 1 ? components[1] * 255 : components[0] * 255)
    let b = Int(components.count > 2 ? components[2] * 255 : components[0] * 255)
    return String(format: "#%02X%02X%02X", r, g, b)
  }
}

// MARK: - Preview

#Preview {
  StyleControlView(viewModel: InstaThoughtViewModel.defaultViewModel)
}
