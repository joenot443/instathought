import Foundation
import SwiftUI
import UIKit

class RenderViewModel {
  var text: String
  var style: Style
  private(set) var renderedText: String = ""
  
  init(text: String, style: Style) {
    self.text = text
    self.style = style
  }
  
  func updateRenderedText(_ text: String) {
    self.renderedText = text
  }
}

// RenderView with UITextView and glyph-based range calculation
class RenderView: UIView {
  var textView: UITextView
  var viewModel: RenderViewModel
  let onTap: () -> Void
  
  init(frame: CGRect, viewModel: RenderViewModel, onTap: @escaping () -> Void) {
    self.viewModel = viewModel
    self.onTap = onTap
    self.textView = UITextView(usingTextLayoutManager: false)
    super.init(frame: frame)
    updateTextView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  func updateTextView() {
    textView.removeConstraints(textView.constraints)
    textView.removeFromSuperview()
    
    textView.isEditable = false
    textView.isScrollEnabled = false
    
    textView.text = viewModel.text
    textView.backgroundColor = UIColor(viewModel.style.backgroundColor) // Apply background color
    textView.translatesAutoresizingMaskIntoConstraints = false
    
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = (viewModel.style.fontSize * viewModel.style.lineHeight) - viewModel.style.fontSize
    paragraphStyle.alignment = viewModel.style.textAlignment.alignment()
    
    guard let font = UIFont(name: viewModel.style.fontName, size: viewModel.style.fontSize) else {
      print("Couldn't find \(viewModel.style.fontName)")
      return
    }
    
    let attributedText = NSAttributedString(
      string: viewModel.text,
      attributes: [
        .font:  font,
        .foregroundColor: UIColor(viewModel.style.foregroundColor),
        .paragraphStyle: paragraphStyle
      ]
    )
    textView.attributedText = attributedText
    
    backgroundColor = UIColor(viewModel.style.backgroundColor)

    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
    textView.addGestureRecognizer(tapGesture)

    addSubview(textView)
    
    // Switch on style.shape
    switch viewModel.style.shape {
    case .fullscreen:
      NSLayoutConstraint.activate([
        textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: viewModel.style.padding),
        textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -viewModel.style.padding),
        textView.topAnchor.constraint(equalTo: topAnchor, constant: viewModel.style.verticalPadding),
        textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -viewModel.style.verticalPadding)
      ])
    case .insta:
      NSLayoutConstraint.activate([
        textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: viewModel.style.padding),
        textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -viewModel.style.padding),
        textView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: viewModel.style.verticalPadding + 36.0),
        textView.bottomAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor, constant: -viewModel.style.verticalPadding)
      ])
      
    case .square:
      NSLayoutConstraint.activate([
        textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: viewModel.style.padding),
        textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -viewModel.style.padding),
        textView.centerYAnchor.constraint(equalTo: centerYAnchor),
        textView.heightAnchor.constraint(equalTo: widthAnchor)
      ])
    }
    
    // Apply padding from the style
    
  }
  
  @objc func handleTap() {
    onTap()
  }
  
  func visibleTextRange() -> NSRange? {
    let layoutManager = textView.layoutManager
    
    // Convert UITextView bounds to the coordinate system used by NSLayoutManager
    let textContainer = textView.textContainer
    let glyphRange = layoutManager.glyphRange(forBoundingRect: textView.bounds, in: textContainer)
    
    if glyphRange.length == 0 {
      return nil // No visible text
    }
    
    // Convert glyph range to character range
    return layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
  }
}

struct RenderViewWrapper: UIViewRepresentable {
  var text: String
  var style: Style
  let onTap: () -> Void
  
  func makeUIView(context: Context) -> RenderView {
    let viewModel = RenderViewModel(text: text, style: style)
    return RenderView(frame: .zero, viewModel: viewModel, onTap: onTap)
  }
  
  func updateUIView(_ uiView: RenderView, context: Context) {
    // Update the view if the text or style changes
    uiView.viewModel.style = style
    uiView.viewModel.text = text
    uiView.updateTextView()
  }
}
