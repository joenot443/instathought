//
//  InstaThoughtApp.swift
//  InstaThought
//
//  Created by Joe Crozier on 9/4/24.
//

import SwiftUI
import AlertToast
import FontPicker

struct TextEditorPage: View {
  @ObservedObject var viewModel: InstaThoughtViewModel
  @State private var isNavigationActive = false
  
  var body: some View {
    VStack {
      // Text editor to edit the note
      TextEditorView(text: $viewModel.text) {
        // No need to trigger RenderService here anymore
      }
      Spacer()
      if !viewModel.text.isEmpty {
        // "Next" button at the bottom to go to the second page
        Button(action: {
          // Perform some action before navigating
          viewModel.requestPreviewRender()
          isNavigationActive = true // Trigger navigation manually
        }) {
          Text("Next")
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .padding(.horizontal)
        }
        // Programmatic navigation using isActive binding
        NavigationLink(
          destination: StyleAndPreviewPage(viewModel: viewModel),
          isActive: $isNavigationActive
        ) {
          EmptyView()
        }
      }
    }
    .background(.black.opacity(0.05))
    .navigationTitle("Your Thoughts")
  }
}

// Second page: Style controls, preview carousel, and buttons
struct StyleAndPreviewPage: View {
  @ObservedObject var viewModel: InstaThoughtViewModel
  
  @State private var isFontSelectorPresented: Bool = false
  
  var body: some View {
    GeometryReader { geometry in
      VStack(alignment: .center) {
        StyleControlView(viewModel: viewModel)
        PreviewCarouselView(isRendering: $viewModel.isRenderingInProgress, previewViewModels: viewModel.previewViewModels)
        PreviewButtonsView(viewModel: viewModel)
      }
      .fontPicker(isPresented: $isFontSelectorPresented, selected: $viewModel.style.fontName)
      .background(Color.gray.opacity(0.1))
    }
    .background(.black.opacity(0.05))
    
    .navigationTitle("Your Style")
    .fontPicker(isPresented: $viewModel.isFontPickerActive, selected: $viewModel.style.fontName)
    .toast(isPresenting: $viewModel.isToastingCompletion, alert: {
      AlertToast(displayMode: .alert, type: .complete(.black.opacity(0.2)), title: "Saved to Camera Roll")
    })
  }
}

struct InstaThoughtView: View {
  @StateObject var viewModel: InstaThoughtViewModel
  
  var body: some View {
    NavigationStack {
      TextEditorPage(viewModel: viewModel)
    }
  }
}

// App entry point
@main
struct InstaThoughtApp: App {
  var body: some Scene {
    WindowGroup {
      InstaThoughtView(viewModel: InstaThoughtViewModel(text: "", style: .defaultStyle, defaultStyles: Style.defaultStyles))
    }
  }
}


#Preview {
  return InstaThoughtView(viewModel: InstaThoughtViewModel(text: "", style: .init(foregroundColor: .black, backgroundColor: .white, fontSize: 12.0), defaultStyles: Style.defaultStyles))
}

