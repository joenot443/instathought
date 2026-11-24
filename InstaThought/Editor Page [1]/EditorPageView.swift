//
//  EditorPageView.swift
//  InstaThought
//
//  Created by Joe Crozier on 3/17/25.
//

import SwiftUI
import AlertToast
import Combine

struct TextEditorPage: View {
  @ObservedObject var viewModel: InstaThoughtViewModel
  @FocusState private var isEditorFocused: Bool
  
  var body: some View {
    VStack(spacing: 0) {
      TextEditorView(text: $viewModel.text) {}
        .focused($isEditorFocused)
        .onChange(of: isEditorFocused) { newValue, _ in
          if newValue {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
              viewModel.isTemplatePickerActive = false
            }
          }
        }
        .onTapGesture {
          viewModel.isTemplatePickerActive = false
          isEditorFocused = true
        }

      Spacer()

      if !viewModel.text.isEmpty {
        PrimaryButton(title: "Continue") {
          let impact = UIImpactFeedbackGenerator(style: .medium)
          impact.impactOccurred()
          viewModel.requestPreviewRender()
          viewModel.shouldNavigateToStyle = true
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
        .transition(.move(edge: .bottom).combined(with: .opacity))
      }
    }
    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: viewModel.text.isEmpty)
    .navigationTitle("Your Thoughts")
    
    // Template view
    TemplateView(selectedText: $viewModel.text, viewModel: viewModel, onSelect: { template in
      viewModel.text = template.content
//      viewModel.style = Style.defaultStyles.randomElement()!.newCopy()
    }, onHeaderTap: {
      isEditorFocused = false
    })
//      .onChange(of: viewModel.text) { newValue, _ in
//        if !newValue.isEmpty && !viewModel.isTemplatePickerActive {
//          withAnimation(.spring()) {
//            viewModel.isTemplatePickerActive = true
//          }
//        }
//      }
      .onAppear {
        viewModel.isTemplatePickerActive = false
      }
      .animation(.spring(), value: viewModel.text.isEmpty)
  }
}
