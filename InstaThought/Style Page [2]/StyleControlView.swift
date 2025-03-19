import Foundation
import UIKit
import FontPicker
import SwiftUI

struct StyleControlView: View {
  @ObservedObject var viewModel: InstaThoughtViewModel
  
  var body: some View {
    VStack {
      HStack {
        // Font Picker
        ActionButton(icon: "textformat.size", label: viewModel.style.fontName) {
          viewModel.isFontPickerActive = true
        }
        
        ActionButton(icon: "paintpalette.fill", label: "Style", action: {
          viewModel.isStylePickerActive = true
        })
        
        // Foreground Color Picker
        ColorPopoverButton(icon: Image.init(.text).renderingMode(.template), color: Theme.shared.colors.accentText, isPresented: $viewModel.isColorPickerActive) { color in
          viewModel.style.foregroundColor = color
        }
        
        ColorPopoverButton(icon: .init(.textBackground).renderingMode(.template), color: Theme.shared.colors.accentText, isPresented: $viewModel.isBackgroundColorPickerActive) { color in
          viewModel.style.backgroundColor = color
        }
      }
      .padding(.top, 10)
      
      HStack {
        // Font Size Adjuster
        AdjusterView(
          icon: "textformat.size",
          iconColor: Theme.shared.colors.accentText,
          value: $viewModel.style.fontSize,
          mode: .continuous(range: 1...100)
        )
        
        ActionButton(icon: viewModel.style.textAlignment.icon(), label: viewModel.style.textAlignment.name(), action: {
          viewModel.style.textAlignment.advance()
        })
        
        // Line Height Adjuster
        AdjusterView(
          icon: "line.horizontal.3.decrease",
          iconColor: .green,
          value: $viewModel.style.lineHeight,
          mode: .stepped(options: Style.defaultLineHeights)
        )
      }
      .padding(.top, 10)
      .sheet(isPresented: $viewModel.isStylePickerActive, content: {
        StyleBrowserView(styles: Style.defaultStyles, text: viewModel.text, onStyleSelected: { style in
          viewModel.style = style
          viewModel.registerBindings()
          viewModel.requestPreviewRender()
        })
      })
      
      HStack {
        // Shape Picker
        ActionButton(icon: viewModel.style.shape.icon(), label: "Shape") {
          viewModel.style.shape.advance()
        }
        
        // Padding Adjuster
        AdjusterView(
          icon: "rectangle.grid.1x2",
          iconColor: Theme.shared.colors.accent,
          value: $viewModel.style.padding,
          mode: .stepped(options: Style.defaultPaddings)
        )
      }
    }
    .padding(.horizontal)
  }
}

// MARK: - Components

struct PickerButton: View {
  let icon: String
  let label: String
  let action: () -> Void
  
  var body: some View {
    HStack(alignment: .center) {
      Spacer()
      Image(systemName: icon).foregroundStyle(.blue.opacity(0.6))
      Text(label).font(.custom(label, size: 14.0))
      Spacer()
    }
    .frame(maxHeight: 24)
    .padding(8)
    .background(Color.gray.opacity(0.1))
    .cornerRadius(6)
    .onTapGesture(perform: action)
  }
}

struct ColorPopoverButton: View {
  var icon: Image
  let color: Color
  @Binding var isPresented: Bool
  let onColorSelected: (Color) -> Void
  
  var body: some View {
    IconButton(icon: icon, color: color)
    {
      isPresented = true
    }
    .popover(isPresented: $isPresented) {
      ColorPickerView(onColorSelected: { selectedColor in
        onColorSelected(selectedColor)
        isPresented = false
      })
      .presentationCompactAdaptation(.sheet)
      .presentationDetents([.fraction(0.3)])
    }
  }
}

// MARK: - Preview

#Preview {
  StyleControlView(viewModel: InstaThoughtViewModel.defaultViewModel)
}
