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
    let textView = UITextView()
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
      uiView.setContentOffset(.zero, animated: true)
    }
  }

  class Coordinator: NSObject, UITextViewDelegate {
    var parent: ScrollableTextEditor

    init(_ textEditor: ScrollableTextEditor) {
      self.parent = textEditor
    }

    func textViewDidChange(_ textView: UITextView) {
      parent.text = textView.text
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
