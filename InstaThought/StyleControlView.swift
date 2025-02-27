//
//  StyleControlView.swift
//  InstaThought
//
//  Created by Joe Crozier on 9/9/24.
//

import Foundation
import UIKit
import FontPicker
import SwiftUI

struct StyleControlView: View {
  @ObservedObject var viewModel: InstaThoughtViewModel
  
  var body: some View {
    VStack() {
      // Color Pickers and Font Size Adjuster
      // Font Picker
      HStack {
        HStack(alignment: .center) {
          Image(systemName: "textformat.size").foregroundStyle(.blue.opacity(0.6))
          Text(viewModel.style.fontName).font(Font.custom(viewModel.style.fontName, size: 12.0))
        }
        .frame(maxHeight: 24)
        .padding(8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(6)
        .onTapGesture {
          viewModel.isFontPickerActive = true
        }
        
        // Foreground Color Picker
        VStack {
          ColorPicker(selection: $viewModel.style.foregroundColor, supportsOpacity: true) {
            Text("A").padding(4).foregroundStyle(.gray).cornerRadius(3.0).bold()
          }
        }
        .frame(maxHeight: 24)
        .padding(8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        
        // Background Color Picker
        HStack {
          ColorPicker(selection: $viewModel.style.backgroundColor, supportsOpacity: true) {
            Text("A").padding(4).foregroundStyle(.white).background(.gray).cornerRadius(3.0).bold()
          }
        }
        .frame(maxHeight: 24)
        .padding(8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        
        Spacer()
      }
      .padding(.top, 10)
      ScrollView(.horizontal) {
        HStack {
          // Font Size Adjuster
          HStack {
            Button(action: {
              $viewModel.style.fontSize.wrappedValue -= 1
            }) {
              Text("-")
                .font(.title)
                .padding(8)
                .background(Color.blue.opacity(0.2))
                .cornerRadius(6)
            }
            VStack {
              Image(systemName: "textformat.size").foregroundStyle(.blue.opacity(0.6))
              Text("\(Int(viewModel.style.fontSize))")
                .padding(.horizontal, 8)
            }
            Button(action: {
              viewModel.style.fontSize += 1
            }) {
              Text("+")
                .font(.title)
                .padding(8)
                .background(Color.blue.opacity(0.2))
                .cornerRadius(6)
            }
          }
          Spacer()
          
          // Padding Adjuster
          HStack {
            Button(action: {
              if let currentIndex = Style.defaultPaddings.firstIndex(of: viewModel.style.padding),
                 currentIndex > 0 {
                viewModel.style.padding = Style.defaultPaddings[currentIndex - 1]
              }
            }) {
              Text("-")
                .font(.title)
                .padding(8)
                .background(Color.green.opacity(0.2))
                .foregroundStyle(Color.green.opacity(0.8))
                .cornerRadius(6)
            }
            VStack {
              Image(systemName: "rectangle.grid.1x2").foregroundStyle(Color.green.opacity(0.6))
              Text("\(Int(viewModel.style.padding))")
                .padding(.horizontal, 8)
            }
            Button(action: {
              if let currentIndex = Style.defaultPaddings.firstIndex(of: viewModel.style.padding),
                 currentIndex < Style.defaultPaddings.count - 1 {
                viewModel.style.padding = Style.defaultPaddings[currentIndex + 1]
              }
            }) {
              Text("+")
                .font(.title)
                .padding(8)
                .background(Color.green.opacity(0.2))
                .foregroundStyle(Color.green.opacity(0.8))
                .cornerRadius(6)
            }
          }
          Spacer()
          
          // Line Height Adjuster
          HStack {
            Button(action: {
              if let currentIndex = Style.defaultLineHeights.firstIndex(of: viewModel.style.lineHeight),
                 currentIndex > 0 {
                viewModel.style.lineHeight = Style.defaultLineHeights[currentIndex - 1]
              }
            }) {
              Text("-")
                .font(.title)
                .padding(8)
                .background(Color.orange.opacity(0.2))
                .foregroundStyle(Color.orange.opacity(0.8))
                .cornerRadius(6)
            }
            VStack {
              Image(systemName: "line.horizontal.3.decrease").foregroundStyle(Color.orange.opacity(0.6))
              Text("\(viewModel.style.lineHeight, specifier: "%.1f")")
                .padding(.horizontal, 8)
            }
            Button(action: {
              if let currentIndex = Style.defaultLineHeights.firstIndex(of: viewModel.style.lineHeight),
                 currentIndex < Style.defaultLineHeights.count - 1 {
                viewModel.style.lineHeight = Style.defaultLineHeights[currentIndex + 1]
              }
            }) {
              Text("+")
                .font(.title)
                .padding(8)
                .background(Color.orange.opacity(0.2))
                .foregroundStyle(Color.orange.opacity(0.8))
                .cornerRadius(6)
            }
          }
        }
      }
      .padding(.top, 10)
      HStack {
        // Style
        NavigationLink(destination: StyleBrowserView(styles: viewModel.defaultStyles, text: viewModel.text) { selectedStyle in
          viewModel.style = selectedStyle
          viewModel.registerBindings()
          viewModel.requestPreviewRender()
        }) {
          HStack {
            Spacer()
            Image(systemName: "paintpalette.fill").foregroundStyle(.blue.opacity(0.6))
            Text("Style").foregroundStyle(.blue.opacity(0.6))
            Spacer()
          }
        }
        .frame(maxHeight: 24)
        .padding(8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(6)
        
        // Shape
        Button(action: {
          viewModel.style.shape.advance()
          
        }) {
          HStack {
            Spacer()
            Image(systemName: viewModel.style.shape.icon()).foregroundStyle(.green.opacity(0.6))
            Text("Shape").foregroundStyle(.green.opacity(0.6))
            Spacer()
          }
        }
        .frame(maxHeight: 24)
        .padding(8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        
        // Alignment
        Button(action: {
          viewModel.style.textAlignment.advance()
        }) {
          HStack {
            Image(systemName: viewModel.style.textAlignment.icon()).foregroundStyle(.orange.opacity(0.6))
          }
        }
        .frame(maxHeight: 24)
        .padding(8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        
        Spacer()
        
      }
    }.padding(.horizontal)
  }
}

#Preview {
  StyleControlView(viewModel: InstaThoughtViewModel.defaultViewModel)
}


