//
//  RenderService.swift
//  InstaThought
//
//  Created by Joe Crozier on 9/4/24.
//

import Foundation
import SwiftUI
import UIKit

class RenderService {
  static func renderPreviews(text: String, style: Style) -> [PreviewViewModel] {
    let startTime = CFAbsoluteTimeGetCurrent()
    let sections = text.components(separatedBy: "\n@")
    var previews: [PreviewViewModel] = []
    
    for section in sections {
      var remainingText = section
      
      while !remainingText.isEmpty {
        let renderView = RenderView(
          frame: CGRect(origin: .zero, size: UIScreen.main.bounds.size),
          viewModel: RenderViewModel(text: remainingText, style: style)
        )
        
        // Attach the view to a temporary window to ensure layout happens
        let tempWindow = UIWindow(frame: UIScreen.main.bounds)
        tempWindow.isHidden = true
        tempWindow.addSubview(renderView)
        
        // Force layout
        tempWindow.layoutIfNeeded()
        renderView.layoutIfNeeded()
        
        // Get the visible text range and rendered text
        if let visibleRange = renderView.visibleTextRange() {
          let renderedText = String(remainingText[remainingText.index(remainingText.startIndex, offsetBy: visibleRange.location)..<remainingText.index(remainingText.startIndex, offsetBy: visibleRange.location + visibleRange.length)])
          
          // Update remaining text by removing the rendered portion
          remainingText = String(remainingText.suffix(remainingText.count - renderedText.count))
          
          // Render the view into an image
          let renderer = UIGraphicsImageRenderer(size: UIScreen.main.bounds.size)
          let image = renderer.image { _ in
            renderView.drawHierarchy(in: renderView.bounds, afterScreenUpdates: true)
          }
          
          // Append the generated preview image to the array
          previews.append(PreviewViewModel(image: image, text: renderedText))
          
          // Clean up: remove the view from the window to avoid memory leaks
          renderView.removeFromSuperview()
        } else {
          break // Break to avoid infinite loop in case of no visible text
        }
      }
    }
    
    let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
    print("Preview rendering completed in \(String(format: "%.3f", timeElapsed)) seconds")
    
    return previews
  }
}
