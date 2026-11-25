import Foundation
import SwiftUI

struct FullPreviewView: View {
  @ObservedObject var viewModel: InstaThoughtViewModel
  @Environment(\.dismiss) private var dismiss
  @Environment(\.openURL) private var openURL
  @State private var isSaving = false
  @State private var currentPage = 0
  @State private var isShowingSaved = false

  private var pageCount: Int { viewModel.previewViewModels.count }

  var body: some View {
    ZStack {
      Cloud.sky.ignoresSafeArea()

      VStack(spacing: 0) {
        HStack {
          CloudBackButton { dismiss() }
          Spacer()
          if pageCount > 1 {
            Text("Page \(currentPage + 1) of \(pageCount)")
              .font(Cloud.font(15, .bold))
              .foregroundStyle(Cloud.quiet)
              .contentTransition(.numericText())
          }
        }
        .cloudBar()

        TabView(selection: $currentPage) {
          ForEach(Array(viewModel.previewViewModels.enumerated()), id: \.element.id) { index, page in
            CloudPage(image: page.image)
              .padding(.horizontal, 32)
              .padding(.vertical, 20)
              .tag(index)
          }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))

        HStack(spacing: 12) {
          Button {
            Cloud.tap()
            ShareService.share(images: viewModel.previewViewModels.map { $0.image })
          } label: {
            Label("Share", systemImage: "square.and.arrow.up")
          }
          .buttonStyle(CloudButtonStyle(kind: .white))
          .frame(width: 132)

          Button {
            Cloud.tap()
            Task { await save() }
          } label: {
            Label("Save to Photos", systemImage: "arrow.down.to.line")
          }
          .buttonStyle(CloudButtonStyle())
          .disabled(isSaving)
        }
        .padding(.horizontal, 20)
        .padding(.top, 6)
        .padding(.bottom, 14)
      }
      .opacity(viewModel.saveAlert == nil ? 1 : 0.4)
      .allowsHitTesting(viewModel.saveAlert == nil)

      if isShowingSaved {
        CloudToast(text: pageCount == 1 ? "Saved 1 page to Photos" : "Saved \(pageCount) pages to Photos")
          .frame(maxHeight: .infinity, alignment: .top)
          .padding(.top, 58)
          .transition(.move(edge: .top).combined(with: .opacity))
      }

      if let alert = viewModel.saveAlert {
        alertView(alert)
          .frame(maxHeight: .infinity, alignment: .bottom)
          .padding(.bottom, 20)
          .transition(.move(edge: .bottom).combined(with: .opacity))
      }
    }
    .animation(.spring(response: 0.35, dampingFraction: 0.8), value: viewModel.saveAlert)
    .animation(.spring(response: 0.35, dampingFraction: 0.75), value: isShowingSaved)
    .toolbar(.hidden, for: .navigationBar)
    .onChange(of: viewModel.isToastingCompletion) { _, saved in
      guard saved else { return }
      isShowingSaved = true
      Task {
        try? await Task.sleep(for: .seconds(2.2))
        isShowingSaved = false
        viewModel.isToastingCompletion = false
      }
    }
  }

  @ViewBuilder
  private func alertView(_ alert: SaveAlert) -> some View {
    switch alert {
    case .photosAccessDenied:
      CloudAlert(
        title: "Photos access is off",
        message: "InstaThought needs permission to add images to Photos before it can save your pages.",
        primary: ("Open Settings", {
          viewModel.saveAlert = nil
          if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
        }),
        secondary: ("Not now", { viewModel.saveAlert = nil })
      )
    case .saveFailed:
      CloudAlert(
        title: "Couldn't save",
        message: "Your pages weren't saved to Photos. Try again in a moment.",
        primary: ("OK", { viewModel.saveAlert = nil })
      )
    }
  }

  /// Stays on Preview either way: a bubble confirms a save, or explains why it failed.
  private func save() async {
    isSaving = true
    defer { isSaving = false }
    _ = await viewModel.saveToPhotos()
  }
}
