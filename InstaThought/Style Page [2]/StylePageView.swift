import SwiftUI

struct StyleAndPreviewPage: View {
  @ObservedObject var viewModel: InstaThoughtViewModel
  @State private var activePanel: StylePanel = .typography

  var body: some View {
    VStack(spacing: 0) {
      PreviewCarouselView(
        isRendering: $viewModel.isRenderingInProgress,
        previewViewModels: viewModel.previewViewModels
      )
      .frame(maxWidth: .infinity, maxHeight: .infinity)

      StyleToolbar(viewModel: viewModel, activePanel: $activePanel)
    }
    .background(Cloud.sky.ignoresSafeArea())
    .cloudNavigationBar()
    .toolbar {
      CloudBarItem {
        // The one sun-yellow control on this screen: the next step.
        Button("Preview") {
          Cloud.tap()
          viewModel.shouldNavigateToPreview = true
        }
        .buttonStyle(CloudChipStyle(fill: Cloud.sun, ink: Cloud.onSun))
      }
    }
    // Preview is pushed from here (not from the editor), so Back from Preview returns to Style.
    .navigationDestination(isPresented: $viewModel.shouldNavigateToPreview) {
      FullPreviewView(viewModel: viewModel)
    }
    .sheet(isPresented: $viewModel.isFontPickerActive) {
      FontPickerView(selectedFont: $viewModel.style.fontName)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
    .sheet(isPresented: $viewModel.isStylePickerActive) {
      StyleBrowserView(styles: Style.defaultStyles, text: viewModel.text, selected: viewModel.style) { style in
        viewModel.apply(preset: style)
      }
    }
  }
}
