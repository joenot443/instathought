//
//  ColorPickerView.swift
//  InstaThought
//
//  Created by Joe Crozier on 3/17/25.
//

import Foundation
import SwiftUI

struct ColorPickerView: View {
  // View model to store colors
  private static let colors: [Color] = [
    .red, .orange, .yellow, .green, .blue,
    .purple, .pink, .brown, .gray, .black,
    .mint, .teal, .cyan, .indigo, .primary,
    .secondary, .white, .clear,
    Color(red: 0.8, green: 0.2, blue: 0.3),
    Color(red: 0.3, green: 0.8, blue: 0.2),
    Color(red: 0.2, green: 0.3, blue: 0.8),
    Color(red: 0.7, green: 0.7, blue: 0.2),
    Color(red: 0.2, green: 0.7, blue: 0.7),
    Color(red: 0.7, green: 0.2, blue: 0.7),
    // Additional colors
    Color(red: 0.9, green: 0.1, blue: 0.1),  // Bright red
    Color(red: 0.1, green: 0.9, blue: 0.1),  // Bright green
    Color(red: 0.1, green: 0.1, blue: 0.9),  // Bright blue
    Color(red: 0.95, green: 0.95, blue: 0.8), // Cream
    Color(red: 0.8, green: 0.6, blue: 0.4),  // Tan
    Color(red: 0.6, green: 0.4, blue: 0.2),  // Brown
    Color(red: 0.4, green: 0.2, blue: 0.0),  // Dark brown
    Color(red: 0.9, green: 0.7, blue: 0.9),  // Light purple
    Color(red: 0.7, green: 0.0, blue: 0.5),  // Magenta
    Color(red: 0.5, green: 0.0, blue: 0.5),  // Deep purple
    Color(red: 0.9, green: 0.5, blue: 0.0),  // Orange
    Color(red: 1.0, green: 0.8, blue: 0.0),  // Golden yellow
    Color(red: 0.0, green: 0.5, blue: 0.3),  // Forest green
    Color(red: 0.0, green: 0.6, blue: 0.6),  // Turquoise
    Color(red: 0.3, green: 0.5, blue: 0.8),  // Sky blue
    Color(red: 0.8, green: 0.3, blue: 0.5),  // Rose
    Color(red: 0.7, green: 0.9, blue: 0.7),  // Mint green
    Color(red: 0.9, green: 0.9, blue: 0.9),  // Light gray
    Color(red: 0.3, green: 0.3, blue: 0.3),  // Dark gray
    Color(red: 0.8, green: 0.8, blue: 0.6),  // Khaki
    Color(red: 0.6, green: 0.8, blue: 0.8),  // Light blue
    Color(red: 0.8, green: 0.6, blue: 0.8),  // Light purple
    Color(red: 0.5, green: 0.2, blue: 0.9),  // Royal purple
    Color(red: 0.9, green: 0.2, blue: 0.5),  // Hot pink
    Color(red: 0.2, green: 0.9, blue: 0.5),  // Spring green
    Color(red: 0.5, green: 0.9, blue: 0.2),  // Lime
    Color(red: 0.9, green: 0.5, blue: 0.2),  // Coral
    Color(red: 0.2, green: 0.5, blue: 0.9),  // Ocean blue
    Color(red: 0.4, green: 0.4, blue: 0.8),  // Periwinkle
    Color(red: 0.7, green: 0.2, blue: 0.7),
  ]
  
  // Callback for color selection
  var onColorSelected: (Color) -> Void
  
  @State private var showSystemPicker = false
  @State private var pickedColor = UIColor.red {
    didSet {
      onColorSelected(Color(pickedColor))
    }
  }
  
  var body: some View {
    Group {
      GeometryReader { proxy in
        let width = proxy.frame(in: .local).height / 3.0
        
        ScrollView(.horizontal, showsIndicators: false) {
          LazyHGrid(rows: [
            GridItem(.fixed(proxy.frame(in: .local).height / 3.0), spacing: 0),
            GridItem(.fixed(proxy.frame(in: .local).height / 3.0), spacing: 0),
            GridItem(.fixed(proxy.frame(in: .local).height / 3.0), spacing: 0)
          ], spacing: 0) {
              Button(action: {
                  showSystemPicker = true
              }) {
                  Image(.colorWheel)
                      .resizable()
                      .frame(width: 44, height: 44)
              }
              .sheet(isPresented: $showSystemPicker) {
                SystemColorPicker(color: $pickedColor, onColorSelected: onColorSelected)
              }
            .frame(width: width, height: width)
            colorCells(width: width)
          }
        }
      }
    }
  }
  
  private func colorCells(width: CGFloat) -> some View {
    ForEach(0..<Self.colors.count, id: \.self) { index in
      ColorCell(color: Self.colors[index])
        .onTapGesture {
          onColorSelected(Self.colors[index])
        }
        .frame(width: width)
    }
  }
}

// Helper view for individual color cells
private struct ColorCell: View {
  let color: Color
  
  var body: some View {
    Rectangle()
      .fill(color)
  }
}

// Preview provider for development
struct ColorPickerView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      ColorPickerView(onColorSelected: { color in
        print("Selected color: \(color)")
      })
      .previewDisplayName("Compact Mode")
      
      ColorPickerView(onColorSelected: { color in
        print("Selected color: \(color)")
      })
      .previewDisplayName("Expanded Mode")
    }
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
        viewController.dismiss(animated: true)
      }
    }
}
