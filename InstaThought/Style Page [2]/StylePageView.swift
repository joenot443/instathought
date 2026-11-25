import SwiftUI

struct StyleAndPreviewPage: View {
  @ObservedObject var viewModel: InstaThoughtViewModel
  @Environment(\.dismiss) private var dismiss
  @State private var activePanel: StylePanel = .typography

  var body: some View {
    VStack(spacing: 0) {
      HStack {
        CloudBackButton { dismiss() }
        Spacer()
        // The one sun-yellow control on this screen: the next step.
        Button("Preview") {
          Cloud.tap()
          viewModel.shouldNavigateToPreview = true
        }
        .buttonStyle(CloudChipStyle(fill: Cloud.sun, ink: Cloud.onSun))
      }
      .cloudBar()

      PreviewCarouselView(
        isRendering: $viewModel.isRenderingInProgress,
        previewViewModels: viewModel.previewViewModels
      )
      .frame(maxWidth: .infinity, maxHeight: .infinity)

      StyleToolbar(viewModel: viewModel, activePanel: $activePanel)
    }
    .background(Cloud.sky.ignoresSafeArea())
    .toolbar(.hidden, for: .navigationBar)
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
