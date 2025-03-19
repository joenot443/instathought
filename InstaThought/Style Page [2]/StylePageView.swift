import SwiftUI
import AlertToast
import Combine

// Second page: Style controls, preview carousel, and buttons
struct StyleAndPreviewPage: View {
  @ObservedObject var viewModel: InstaThoughtViewModel
  
  @State private var isFontSelectorPresented: Bool = false
  @State private var title: String = "Editable Title"

  var body: some View {
    GeometryReader { geometry in
      VStack(alignment: .center, spacing: 8.0) {
        StyleControlView(viewModel: viewModel)
        PreviewCarouselView(isRendering: $viewModel.isRenderingInProgress, previewViewModels: viewModel.previewViewModels)
        PreviewButtonsView(viewModel: viewModel)
      }
      .fontPicker(isPresented: $isFontSelectorPresented, selected: $viewModel.style.fontName)
    }
    .navigationTitle($title)
    .fontPicker(isPresented: $viewModel.isFontPickerActive, selected: $viewModel.style.fontName)
    .toast(isPresenting: $viewModel.isToastingCompletion, alert: {
      AlertToast(displayMode: .alert, type: .complete(Theme.shared.colors.primaryText), title: "Saved to Camera Roll")
    })
  }
}

