//
//  ColorPickerView.swift
//  InstaThought
//
//  Created by Joe Crozier on 3/17/25.
//

import Foundation
import SwiftUI

/// A sheet of swatches: neutrals, then a row per hue from light to dark. The colour in use wears
/// a ring. Tapping a swatch recolours the page straight away; Custom opens the system picker.
struct ColorPickerView: View {
  let title: String
  let selected: Color
  var onColorSelected: (Color) -> Void
  @Environment(\.dismiss) private var dismiss
  @State private var showSystemPicker = false
  @State private var pickedColor = UIColor.red

  private static let hues = ["Red", "Pink", "Grape", "Violet", "Indigo", "Blue", "Cyan", "Teal", "Green", "Lime", "Yellow", "Orange"]
  private static let shades = [0, 1, 2, 4, 5, 6, 7, 8, 9]

  /// (name, colour) rows of nine.
  private static let rows: [[(String, Color)]] = {
    let all = Color.allColors
    // all = white, black, gray 0 2 3 4 5 6 7 8 9, then each hue's nine shades.
    let neutrals: [(String, Color)] = [("White", all[0]), ("Gray 0", all[2]), ("Gray 2", all[3]), ("Gray 3", all[4]),
      ("Gray 5", all[6]), ("Gray 6", all[7]), ("Gray 7", all[8]), ("Gray 9", all[10]), ("Black", all[1])]
    var out = [neutrals]
    for (h, hue) in hues.enumerated() {
      let start = 11 + h * 9
      guard start + 9 <= all.count else { break }
      out.append((0..<9).map { ("\(hue) \(shades[$0])", all[start + $0]) })
    }
    return out
  }()

  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 10) {
        Text(title).font(Cloud.font(22, .black))
        Spacer()
        Button {
          Cloud.tap()
          pickedColor = UIColor(selected)
          showSystemPicker = true
        } label: {
          Label("Custom", systemImage: "eyedropper")
        }
        .buttonStyle(CloudChipStyle())
        Button("Done") {
          Cloud.tap()
          dismiss()
        }
        .buttonStyle(CloudChipStyle(fill: Cloud.sun, ink: Cloud.onSun))
      }
      .padding(.horizontal, 18)
      .padding(.top, 18)
      .padding(.bottom, 8)

      ScrollView {
        Grid(horizontalSpacing: 6, verticalSpacing: 6) {
          ForEach(Self.rows.indices, id: \.self) { r in
            GridRow {
              ForEach(Self.rows[r].indices, id: \.self) { c in
                let (name, color) = Self.rows[r][c]
                Swatch(color: color, isSelected: color.matches(selected)) {
                  Cloud.tick()
                  onColorSelected(color)
                }
                .accessibilityLabel(name)
              }
            }
          }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 24)
      }
    }
    .foregroundStyle(Cloud.night)
    .background(Cloud.white.ignoresSafeArea())
    .sheet(isPresented: $showSystemPicker) {
      SystemColorPicker(color: $pickedColor, onColorSelected: onColorSelected)
    }
  }
}

/// A round swatch. Chosen: a ring with a gap, so the colour itself is never covered.
private struct Swatch: View {
  let color: Color
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Circle()
        .fill(color)
        .overlay(Circle().strokeBorder(Cloud.edge.opacity(0.14), lineWidth: 1))
        .padding(isSelected ? 5 : 2)
        .overlay(Circle().strokeBorder(Cloud.stroke, lineWidth: isSelected ? 3 : 0))
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: 40)
        .contentShape(Circle())
    }
    .buttonStyle(SwatchPressStyle())
    .accessibilityAddTraits(isSelected ? .isSelected : [])
    .animation(.snappy(duration: 0.18), value: isSelected)
  }
}

private struct SwatchPressStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaleEffect(configuration.isPressed ? 0.88 : 1)
      .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
  }
}

extension Color {
  /// Same colour to within rounding, so a stored colour still finds its swatch.
  func matches(_ other: Color) -> Bool {
    var a: (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0), b = a
    UIColor(self).getRed(&a.0, green: &a.1, blue: &a.2, alpha: &a.3)
    UIColor(other).getRed(&b.0, green: &b.1, blue: &b.2, alpha: &b.3)
    return abs(a.0 - b.0) < 0.01 && abs(a.1 - b.1) < 0.01 && abs(a.2 - b.2) < 0.01
  }
}

struct SystemColorPicker: UIViewControllerRepresentable {
    @Binding var color: UIColor
  var onColorSelected: (Color) -> Void
    
    func makeUIViewController(context: Context) -> UIColorPickerViewController {
        let picker = UIColorPickerViewController()
        picker.selectedColor = color
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIColorPickerViewController, context: Context) {
        uiViewController.selectedColor = color
    }
    
    func makeCoordinator() -> Coordinator {
      Coordinator(color: $color, onColorSelected: onColorSelected)
    }
    
    class Coordinator: NSObject, UIColorPickerViewControllerDelegate {
        @Binding var color: UIColor
      var onColorSelected: (Color) -> Void

      init(color: Binding<UIColor>, onColorSelected: @escaping (Color) -> Void
) {
          self.onColorSelected = onColorSelected
            _color = color
        }
        
        func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
            color = viewController.selectedColor
        }
      
      func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        color = viewController.selectedColor
        onColorSelected(Color(color))
      }
    }
}
