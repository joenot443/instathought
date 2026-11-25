//
//  EditorPageView.swift
//  InstaThought
//
//  Created by Joe Crozier on 3/17/25.
//

import SwiftUI
import Combine

struct TextEditorPage: View {
  @ObservedObject var viewModel: InstaThoughtViewModel
  @State private var isKeyboardVisible = false

  var body: some View {
    VStack(spacing: 0) {
      HStack {
        CloudWordmark()
        Spacer()
        if isKeyboardVisible {
          Button("Done") {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
          }
          .buttonStyle(CloudChipStyle())
        } else {
          Button {
            Cloud.tap()
            viewModel.isTemplatePickerActive = true
          } label: {
            Label("Ideas", systemImage: "lightbulb")
          }
          .buttonStyle(CloudChipStyle())
        }
      }
      .cloudBar()

      TextEditorView(text: $viewModel.text, pageCount: viewModel.previewViewModels.count)
        .padding(.horizontal, 20)
        .padding(.top, 10)

      // The bubble's trail leads down to the next step.
      ZStack(alignment: .topLeading) {
        if !isKeyboardVisible {
          Circle().fill(Cloud.white).overlay(Circle().strokeBorder(Cloud.night, lineWidth: 3))
            .frame(width: 30, height: 30)
            .offset(x: 24, y: 12)
          Circle().fill(Cloud.white).overlay(Circle().strokeBorder(Cloud.night, lineWidth: 3))
            .frame(width: 17, height: 17)
            .offset(x: 52, y: 48)
        }
        Button("Make it a page") {
          Cloud.tap()
          viewModel.requestPreviewRender()
          viewModel.shouldNavigateToStyle = true
        }
        .buttonStyle(CloudButtonStyle())
        .disabled(viewModel.text.isEmpty)
        .padding(.leading, isKeyboardVisible ? 0 : 84)
        .padding(.top, isKeyboardVisible ? 14 : 58)
      }
      .padding(.horizontal, 20)
      .padding(.bottom, 12)
      .animation(.snappy(duration: 0.25), value: isKeyboardVisible)
    }
    .background(Cloud.sky.ignoresSafeArea())
    .toolbar(.hidden, for: .navigationBar)
    .sheet(isPresented: $viewModel.isTemplatePickerActive) {
      InspirationSheet { template in
        viewModel.text = template.content
      }
    }
    .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
      isKeyboardVisible = true
    }
    .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
      isKeyboardVisible = false
    }
  }
}
