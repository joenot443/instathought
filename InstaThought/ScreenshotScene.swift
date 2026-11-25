//
//  ScreenshotScene.swift
//  InstaThought
//
//  DEBUG-only: launch with `-screenshotScene <name>` to open the app directly on a given
//  screen, for App Store screenshots and review. Not compiled into Release builds.
//

#if DEBUG
import SwiftUI

enum ScreenshotScene: String, CaseIterable {
  case intro, editor, inspiration, editorText, style, styleBrowser, fontPicker, preview, share, saved, photosDenied

  static let current: ScreenshotScene? = {
    let args = ProcessInfo.processInfo.arguments
    guard let index = args.firstIndex(of: "-screenshotScene"), index + 1 < args.count else { return nil }
    return ScreenshotScene(rawValue: args[index + 1])
  }()

  /// Every scene starts from a clean draft so the screenshots don't depend on earlier runs.
  static func prepareLaunch() {
    if current != nil {
      DraftStore.clear()
    }
  }

  private static let sampleTitle = "Pride and Prejudice"
  /// The lavender Poppins preset, which is also the default style for new thoughts.
  private static let sampleStyleIndex = Style.defaultStyles.firstIndex { $0.fontName == "Poppins-Medium" } ?? 0

  @MainActor
  func apply(to viewModel: InstaThoughtViewModel) async {
    switch self {
    case .intro, .editor:
      return
    case .inspiration:
      await pause(0.6)
      withAnimation { viewModel.isTemplatePickerActive = true }
      return
    default:
      break
    }

    viewModel.text = Template.samples.first { $0.title == Self.sampleTitle }?.content ?? String.longNumbers
    viewModel.style = Style.defaultStyles[Self.sampleStyleIndex]
    viewModel.registerBindings()
    viewModel.requestPreviewRender()
    if self == .editorText { return }

    await pause(0.4)
    viewModel.shouldNavigateToStyle = true
    await pause(0.8)

    switch self {
    case .styleBrowser:
      viewModel.isStylePickerActive = true
    case .fontPicker:
      viewModel.isFontPickerActive = true
    case .preview, .share, .saved, .photosDenied:
      viewModel.shouldNavigateToPreview = true
      await pause(0.8)
      if self == .share {
        ShareService.share(images: viewModel.previewViewModels.map { $0.image })
      } else if self == .photosDenied || self == .saved {
        _ = await viewModel.saveToPhotos()
      }
    default:
      break
    }
  }

  private func pause(_ seconds: Double) async {
    try? await Task.sleep(for: .seconds(seconds))
  }
}
#endif
