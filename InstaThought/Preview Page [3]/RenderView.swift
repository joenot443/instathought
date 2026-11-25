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
        // The screen's safe area as fixed numbers rather than the safe-area guide: pages are laid
        // out off screen, where the guide reads zero while measuring but applies when drawing,
        // which used to clip the last lines of a page.
        textView.topAnchor.constraint(equalTo: topAnchor, constant: Self.screenSafeArea.top + viewModel.style.verticalPadding + 36.0),
        textView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -(Self.screenSafeArea.bottom + viewModel.style.verticalPadding))
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
  
  /// The safe-area insets of the app's window, which is what a page is laid out to match.
  static var screenSafeArea: UIEdgeInsets {
    UIApplication.shared.connectedScenes
      .compactMap { ($0 as? UIWindowScene)?.windows.first { $0.isKeyWindow } }
      .first?.safeAreaInsets ?? .zero
  }

  @objc func handleTap() {
    onTap()
  }
  
  func visibleTextRange() -> NSRange? {
    let layoutManager = textView.layoutManager
    
    // Convert UITextView bounds to the coordinate system used by NSLayoutManager
    let textContainer = textView.textContainer
    // Only lines that fit completely count as on this page. A line cut off at the bottom
    // edge used to count too, so it was clipped here and never carried to the next page.
    let inset = textView.textContainerInset
    let visibleHeight = textView.bounds.height - inset.top - inset.bottom
    let allGlyphs = layoutManager.glyphRange(for: textContainer)
    var lastGlyph: Int?
    layoutManager.enumerateLineFragments(forGlyphRange: allGlyphs) { rect, _, _, lineRange, stop in
      // The first line always counts, even if it's taller than the page, so text never stalls.
      if rect.maxY <= visibleHeight + 0.5 || lastGlyph == nil {
        lastGlyph = NSMaxRange(lineRange)
      } else {
        stop.pointee = true
      }
    }
    guard let lastGlyph, lastGlyph > 0 else {
      return nil // No line fits
    }

    // Convert glyph range to character range
    return layoutManager.characterRange(forGlyphRange: NSRange(location: 0, length: lastGlyph), actualGlyphRange: nil)
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
