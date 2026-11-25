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
      // Half height, so the page stays in view and changes as you pick.
      FontPickerView(selectedFont: $viewModel.style.fontName, sample: viewModel.text)
        .chooserSheet()
    }
    // The colour sheets live here, not in the Color tab, so they open whichever tab is showing.
    .sheet(isPresented: $viewModel.isColorPickerActive) {
      ColorPickerView(title: "Text", selected: viewModel.style.foregroundColor) { viewModel.style.foregroundColor = $0 }
        .chooserSheet()
    }
    .sheet(isPresented: $viewModel.isBackgroundColorPickerActive) {
      ColorPickerView(title: "Background", selected: viewModel.style.backgroundColor) { viewModel.style.backgroundColor = $0 }
        .chooserSheet()
    }
    .sheet(isPresented: $viewModel.isStylePickerActive) {
      StyleBrowserView(styles: Style.defaultStyles, text: viewModel.text, selected: viewModel.style) { style in
        viewModel.apply(preset: style)
      }
    }
  }
}

extension View {
  /// Font and colour choosers: just over half height, with the page above left undimmed,
  /// so it can be watched changing as you choose.
  func chooserSheet() -> some View {
    presentationDetents([.fraction(0.56), .large])
      .presentationBackgroundInteraction(.enabled(upThrough: .fraction(0.56)))
      .presentationContentInteraction(.scrolls)
      .presentationDragIndicator(.visible)
      .presentationCornerRadius(34)
  }
}
