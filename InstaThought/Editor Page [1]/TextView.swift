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
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  func makeUIView(context: Context) -> UITextView {
    let textView = UITextView()
    textView.delegate = context.coordinator
    textView.font = font
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

struct TextEditorView: View {
  @Binding var text: String
  @FocusState private var isFocused: Bool
  @Environment(\.colorScheme) private var colorScheme
  let action: () -> Void

  var body: some View {
    VStack(spacing: 0) {
      ZStack(alignment: .topLeading) {
        ScrollableTextEditor(text: $text, font: .init(name: "Lato-Regular", size: 22) ?? .systemFont(ofSize: 22))
          .focused($isFocused)
          .tint(Theme.shared.colors.accentMedium)
          .foregroundStyle(Theme.shared.colors.primaryText)
          .padding(.horizontal, 4)
          .padding(.vertical, 8)
          .contentMargins(8.0)

        if text.isEmpty {
          Text(verbatim: "What's on your mind?")
            .font(.custom("Lato-Regular", size: 22))
            .padding(.vertical, 16)
            .padding(.horizontal, 12)
            .foregroundStyle(Color.secondary.opacity(0.5))
            .allowsHitTesting(false)
        }
      }
      .padding(12)
      .background(
        RoundedRectangle(cornerRadius: 12)
          .fill(Color(UIColor.secondarySystemBackground))
      )
      .overlay(
        RoundedRectangle(cornerRadius: 12)
          .stroke(isFocused ? Theme.shared.colors.accentMedium.opacity(0.5) : Color.clear, lineWidth: 2)
      )
      .padding(.horizontal, 20)
      .padding(.top, 8)

      // Character count when typing
      if !text.isEmpty {
        HStack {
          Spacer()
          Text("\(text.count) characters")
            .font(.caption)
            .foregroundStyle(.tertiary)
            .padding(.trailing, 24)
            .padding(.top, 6)
        }
      }
    }
  }
}
