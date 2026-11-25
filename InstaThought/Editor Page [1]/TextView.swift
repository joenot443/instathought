//
//  InstaThoughtView.swift
//  InstaThought
//
//  Created by Joe Crozier on 9/4/24.
//
import Combine
import SwiftUI

struct ScrollableTextEditor: UIViewRepresentable {
  @Binding var text: String
  let font: UIFont
  var textColor: UIColor = .label
  var tintColor: UIColor? = nil

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  func makeUIView(context: Context) -> UITextView {
    // A TextKit 1 stack with a layout manager that draws page breaks as dividers.
    let storage = NSTextStorage()
    let layoutManager = PageBreakLayoutManager()
    storage.addLayoutManager(layoutManager)
    let container = NSTextContainer(size: CGSize(width: 0, height: CGFloat.greatestFiniteMagnitude))
    container.widthTracksTextView = true
    layoutManager.addTextContainer(container)
    let textView = UITextView(frame: .zero, textContainer: container)
    textView.delegate = context.coordinator
    textView.font = font
    textView.textColor = textColor
    if let tintColor { textView.tintColor = tintColor }
    textView.backgroundColor = .clear
    return textView
  }

  func updateUIView(_ uiView: UITextView, context: Context) {
    if uiView.text != text {
      uiView.text = text
      styleBreaks(in: uiView)
      uiView.setContentOffset(.zero, animated: true)
    }
  }

  /// A line starting with "@" begins a new page (see RenderService). The "@" stays in the text
  /// but is hidden, and the line gets room above it for the divider the layout manager draws.
  fileprivate func styleBreaks(in textView: UITextView) {
    let storage = textView.textStorage
    let whole = NSRange(location: 0, length: storage.length)
    let base: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: textColor]
    storage.beginEditing()
    storage.setAttributes(base, range: whole)
    let marker = ("@" as NSString).size(withAttributes: [.font: font]).width
    for index in PageBreakLayoutManager.breakIndices(in: storage.string as NSString) {
      let paragraph = NSMutableParagraphStyle()
      paragraph.paragraphSpacingBefore = PageBreakLayoutManager.spacing
      storage.addAttribute(.paragraphStyle, value: paragraph,
                           range: (storage.string as NSString).paragraphRange(for: NSRange(location: index, length: 0)))
      // Invisible, and pulled back so the line's text starts at the margin.
      storage.addAttributes([.foregroundColor: UIColor.clear, .kern: -marker], range: NSRange(location: index, length: 1))
    }
    storage.endEditing()
    textView.typingAttributes = base
  }

  class Coordinator: NSObject, UITextViewDelegate {
    var parent: ScrollableTextEditor

    init(_ textEditor: ScrollableTextEditor) {
      self.parent = textEditor
    }

    func textViewDidChange(_ textView: UITextView) {
      // Restyling mid-composition (Japanese, Chinese input) would break the composition.
      if textView.markedTextRange == nil {
        parent.styleBreaks(in: textView)
      }
      parent.text = textView.text
    }
  }
}

/// Draws a faint dashed "page break" divider above each line that starts a new page.
final class PageBreakLayoutManager: NSLayoutManager {
  static let spacing: CGFloat = 30

  /// Positions of "@" characters that start a line (not the very first line), as RenderService splits on "\n@".
  static func breakIndices(in text: NSString) -> [Int] {
    var out: [Int] = []
    var search = NSRange(location: 0, length: text.length)
    while true {
      let found = text.range(of: "\n@", options: [], range: search)
      guard found.location != NSNotFound else { break }
      out.append(found.location + 1)
      let next = found.location + 1
      search = NSRange(location: next, length: text.length - next)
    }
    return out
  }

  override func drawBackground(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
    super.drawBackground(forGlyphRange: glyphsToShow, at: origin)
    guard let storage = textStorage, let container = textContainers.first else { return }
    let chars = characterRange(forGlyphRange: glyphsToShow, actualGlyphRange: nil)
    let font = UIFont(name: "Nunito-Bold", size: 12) ?? .systemFont(ofSize: 12, weight: .bold)
    let label = "page break" as NSString
    let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: Cloud.uiQuiet.withAlphaComponent(0.8)]
    let labelSize = label.size(withAttributes: attributes)
    let left = origin.x + container.lineFragmentPadding
    let right = origin.x + container.size.width - container.lineFragmentPadding
    for index in Self.breakIndices(in: storage.string as NSString) where NSLocationInRange(index, chars) {
      let line = lineFragmentRect(forGlyphAt: glyphIndexForCharacter(at: index), effectiveRange: nil)
      let y = origin.y + line.minY + Self.spacing / 2
      let gap = labelSize.width / 2 + 8
      let middle = (left + right) / 2
      let path = UIBezierPath()
      path.move(to: CGPoint(x: left, y: y)); path.addLine(to: CGPoint(x: middle - gap, y: y))
      path.move(to: CGPoint(x: middle + gap, y: y)); path.addLine(to: CGPoint(x: right, y: y))
      path.lineWidth = 1.5
      path.setLineDash([5, 4], count: 2, phase: 0)
      Cloud.uiQuiet.withAlphaComponent(0.5).setStroke()
      path.stroke()
      label.draw(at: CGPoint(x: middle - labelSize.width / 2, y: y - labelSize.height / 2), withAttributes: attributes)
    }
  }
}

/// The writing area: a big outlined thought bubble.
struct TextEditorView: View {
  @Binding var text: String
  /// Number of rendered pages, shown in the corner once there is text.
  let pageCount: Int

  var body: some View {
    ZStack(alignment: .topLeading) {
      ScrollableTextEditor(
        text: $text,
        font: Cloud.uiFont(22, .semibold),
        textColor: Cloud.uiNight,
        tintColor: Cloud.uiNight
      )
      .padding(.horizontal, 16)
      .padding(.top, 14)
      .padding(.bottom, 34)

      if text.isEmpty {
        Text(verbatim: "What's on your mind?")
          .font(Cloud.font(22, .semibold))
          .foregroundStyle(Cloud.placeholder)
          .padding(.horizontal, 21)
          .padding(.top, 21)
          .allowsHitTesting(false)
          .accessibilityHidden(true)
      }
    }
    .overlay(alignment: .bottomTrailing) {
      if !text.isEmpty, pageCount > 0 {
        Text(pageCount == 1 ? "1 page" : "\(pageCount) pages")
          .font(Cloud.font(14, .bold))
          .foregroundStyle(Cloud.quiet)
          .padding(.trailing, 24)
          .padding(.bottom, 16)
          .contentTransition(.numericText())
      }
    }
    .cloudOutlined(radius: 46, lineWidth: 3)
  }
}
