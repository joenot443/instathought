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
    VStack(spacing: 15) {
      ZStack(alignment: .leading) {
        if text.isEmpty {
          VStack {
            Text("What's on your mind?\n\nYou can start a new line with @ for a new page.")
              .font(.custom("Helvetica", size: 24))
              .padding(.vertical, 8.0)
              .padding(.horizontal, 4.0)
              .foregroundStyle(colorScheme == .dark ? .white.opacity(0.4) : .secondary.opacity(0.4))
            Spacer()
          }
        }
        
        ScrollableTextEditor(text: $text, font: .init(name: "Helvetica", size: 24) ?? .systemFont(ofSize: 24))
          .focused($isFocused)
          .tint(colorScheme == .dark ? .white : .blue)
          .foregroundStyle(.secondary)
          .cornerRadius(8)
          .opacity(text.isEmpty ? 0.25 : 1)
          .contentMargins(8.0)
      }
      .padding(16.0)
    }
  }
}

struct PreviewButtonsView: View {
  @ObservedObject var viewModel: InstaThoughtViewModel
  @State private var isPreviewActive = false
  
  var body: some View {
    VStack {
      HStack {
        Spacer()
        NavigationLink(destination: FullPreviewView(viewModel: viewModel), isActive: $isPreviewActive) {
          EmptyView()
        }
        .hidden()
        
        PrimaryButton(title: "Preview") {
          isPreviewActive = true
        }
        
        Spacer()
      }
    }
  }
}
