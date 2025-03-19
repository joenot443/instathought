//
//  PreviewCarouselView.swift
//  InstaThought
//
//  Created by Joe Crozier on 3/17/25.
//

import Foundation
import UIKit
import SwiftUI

class PreviewViewModel: Identifiable {
  let image: UIImage
  let text: String
  internal let id: UUID
  
  init(image: UIImage, text: String) {
    self.text = text
    self.image = image
    self.id = UUID()
  }
}

struct PreviewCarouselView: View {
  @Binding var isRendering: Bool
  var previewViewModels: [PreviewViewModel]
  
  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack {
        if (isRendering) {
          ProgressView("Generating preview...")
        } else {
          ForEach(previewViewModels) { previewViewModel in
            Image(uiImage: previewViewModel.image)
              .resizable()
              .clipShape(RoundedRectangle(cornerRadius: 8.0))
              .aspectRatio(contentMode: .fill)
              .frame(maxHeight: .infinity)
              .overlay(
                RoundedRectangle(cornerRadius: 8.0)
                  .fill(.clear)
                  .stroke(Color.secondary.opacity(0.5), lineWidth: 0.5)
              )
          }
        }
      }
      .padding(.horizontal)
      .padding(.vertical)
    }
    .background(Color.gray.opacity(0.1))
    .cornerRadius(8)
    .padding(.horizontal)
  }
}
