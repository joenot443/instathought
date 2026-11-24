//
//  InstaThoughtApp.swift
//  InstaThought
//
//  Created by Joe Crozier on 9/4/24.
//

import SwiftUI
import AlertToast
import FontPicker
import Combine

@main
struct InstaThoughtApp: App {
  @StateObject private var theme: Theme = Theme.shared
  @State private var opacity: Double = 0.0
  @State private var showSplash: Bool = false
  
  var body: some Scene {
    WindowGroup {
      ZStack {
        InstaThoughtView(viewModel: InstaThoughtViewModel(text: "", style: .defaultStyle))
          .environmentObject(theme)
      }
    }
  }
}

struct InstaThoughtView: View {
  @StateObject var viewModel: InstaThoughtViewModel

  var body: some View {
    NavigationStack {
      TextEditorPage(viewModel: viewModel)
        .navigationDestination(isPresented: $viewModel.shouldNavigateToStyle) {
          StyleAndPreviewPage(viewModel: viewModel)
        }
        .navigationDestination(isPresented: $viewModel.shouldNavigateToPreview) {
          FullPreviewView(viewModel: viewModel)
            .tint(viewModel.previewViewModels.first?.image.shouldUseWhiteText == true ? .white : Theme.shared.colors.accentText)
        }
    }.tint(Theme.shared.colors.accentText)
  }
}

#Preview {
  return InstaThoughtView(viewModel: InstaThoughtViewModel(text: "AAA", style: .init(foregroundColor: .black, backgroundColor: .white, fontSize: 12.0)))
}
