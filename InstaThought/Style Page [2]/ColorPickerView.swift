//
//  ColorPickerView.swift
//  InstaThought
//
//  Created by Joe Crozier on 3/17/25.
//

import Foundation
import SwiftUI

struct ColorPickerView: View {
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
    ForEach(0..<Color.allColors.count, id: \.self) { index in
      ColorCell(color: Color.allColors[index])
        .onTapGesture {
          onColorSelected(Color.allColors[index])
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
      }
    }
}
