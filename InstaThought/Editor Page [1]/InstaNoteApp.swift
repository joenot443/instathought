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
  @StateObject private var viewModel: InstaThoughtViewModel
  @Environment(\.scenePhase) private var scenePhase

  init() {
    #if DEBUG
    ScreenshotScene.prepareLaunch()
    #endif
    _viewModel = StateObject(wrappedValue: .restored())
  }

  var body: some Scene {
    WindowGroup {
      ZStack {
        #if DEBUG
        if ScreenshotScene.current == .intro {
          IntroView()
        } else {
          InstaThoughtView(viewModel: viewModel)
            .environmentObject(theme)
            .task { await ScreenshotScene.current?.apply(to: viewModel) }
        }
        #else
        InstaThoughtView(viewModel: viewModel)
          .environmentObject(theme)
        #endif
      }
    }
    .onChange(of: scenePhase) { _, phase in
      if phase != .active {
        viewModel.saveDraft()
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
