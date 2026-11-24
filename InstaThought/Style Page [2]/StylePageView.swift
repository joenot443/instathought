import SwiftUI
import AlertToast

struct StyleAndPreviewPage: View {
    @ObservedObject var viewModel: InstaThoughtViewModel
    @State private var activePanel: StylePanel = .none

    var body: some View {
        VStack(spacing: 0) {
            // Preview area - takes all available space
            PreviewCarouselView(
                isRendering: $viewModel.isRenderingInProgress,
                previewViewModels: viewModel.previewViewModels
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onTapGesture {
                // Dismiss panel when tapping preview
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    activePanel = .none
                }
            }

            // Style toolbar with expandable panels
            StyleToolbar(viewModel: viewModel, activePanel: $activePanel)

            // Preview button
            PrimaryButton(title: "Preview") {
                viewModel.shouldNavigateToPreview = true
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
        }
        .background(Color(UIColor.systemBackground))
        .sheet(isPresented: $viewModel.isFontPickerActive) {
            FontPickerView(selectedFont: $viewModel.style.fontName)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $viewModel.isStylePickerActive) {
            StyleBrowserView(styles: Style.defaultStyles, text: viewModel.text, onStyleSelected: { style in
                viewModel.style = style
                viewModel.registerBindings()
                viewModel.requestPreviewRender()
            })
        }
        .toast(isPresenting: $viewModel.isToastingCompletion, alert: {
            AlertToast(displayMode: .alert, type: .complete(Theme.shared.colors.primaryText), title: "Saved to Camera Roll")
        })
        .navigationBarTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}
