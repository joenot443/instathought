import Foundation
import SwiftUI

struct FullPreviewView: View {
  @ObservedObject var viewModel: InstaThoughtViewModel
  @Environment(\.dismiss) var dismiss
  @Environment(\.openURL) private var openURL
  @State private var isSaving = false

  private var useWhiteText: Bool {
    viewModel.previewViewModels.first?.image.shouldUseWhiteText ?? false
  }

  var body: some View {
    NavigationView {
      ZStack(alignment: .bottom) {
        // Paginated image carousel
        TabView {
          ForEach(viewModel.previewViewModels) { previewViewModel in
            Image(uiImage: previewViewModel.image)
              .resizable()
              .scaledToFit()
              .frame(maxWidth: .infinity, maxHeight: .infinity)
              .background(Color.black)
              .ignoresSafeArea()
          }
        }
        .tabViewStyle(PageTabViewStyle())
        .background(Color.black)
        .ignoresSafeArea()

        // Bottom semitransparent menu
        HStack(spacing: 12) {
          previewButton(title: "Share", systemImage: "square.and.arrow.up") {
            ShareService.share(images: viewModel.previewViewModels.map { $0.image })
          }
          previewButton(title: "Save", systemImage: "arrow.down.to.line") {
            Task { await save() }
          }
          .disabled(isSaving)
        }
        .padding(.horizontal)
      }
    }
    .alert(item: $viewModel.saveAlert) { alert in
      switch alert {
      case .photosAccessDenied:
        return Alert(
          title: Text("Photos Access Is Off"),
          message: Text("To save your pages, allow InstaThought to add photos in Settings."),
          primaryButton: .default(Text("Open Settings")) {
            if let url = URL(string: UIApplication.openSettingsURLString) {
              openURL(url)
            }
          },
          secondaryButton: .cancel(Text("Not Now"))
        )
      case .saveFailed:
        return Alert(
          title: Text("Couldn't Save"),
          message: Text("Your pages weren't saved to Photos. Please try again."),
          dismissButton: .default(Text("OK"))
        )
      }
    }
  }

  private func save() async {
    isSaving = true
    defer { isSaving = false }
    if await viewModel.saveToPhotos() {
      dismiss()
    }
  }

  private func previewButton(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
    // A frosted background keeps the buttons legible over the page text.
    Button(action: action) {
      Label(title, systemImage: systemImage)
        .font(.system(size: 17, weight: .semibold))
        .frame(maxWidth: .infinity)
        .padding()
        .foregroundStyle(useWhiteText ? .white : Theme.shared.colors.accentText)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .environment(\.colorScheme, useWhiteText ? .dark : .light)
    }
  }
}
