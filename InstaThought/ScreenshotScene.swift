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
  case editor, inspiration, editorText, style, styleBrowser, fontPicker, colorPicker, preview, share, saved, photosDenied
  /// One group of controls on its own, for before/after crops: `-screenshotScene controls -group chips`.
  case controls

  static let current: ScreenshotScene? = {
    let args = ProcessInfo.processInfo.arguments
    guard let index = args.firstIndex(of: "-screenshotScene"), index + 1 < args.count else { return nil }
    return ScreenshotScene(rawValue: args[index + 1])
  }()

  /// Every scene starts from a clean draft and font shelf so the screenshots don't depend on earlier runs.
  static func prepareLaunch() {
    if current != nil {
      DraftStore.clear()
      UserDefaults.standard.removeObject(forKey: "fonts.starred")
      UserDefaults.standard.removeObject(forKey: "fonts.recent")
    }
  }

  static var group: String {
    let args = ProcessInfo.processInfo.arguments
    guard let index = args.firstIndex(of: "-group"), index + 1 < args.count else { return "chips" }
    return args[index + 1]
  }

  static let sampleText = Template.samples.first { $0.title == sampleTitle }?.content ?? String.longNumbers
  static var sampleStyle: Style { Style.defaultStyles[sampleStyleIndex] }

  private static let sampleTitle = "Pride and Prejudice"
  /// The lavender Poppins preset, which is also the default style for new thoughts.
  private static let sampleStyleIndex = Style.defaultStyles.firstIndex { $0.fontName == "Poppins-Medium" } ?? 0

  @MainActor
  func apply(to viewModel: InstaThoughtViewModel) async {
    switch self {
    case .editor:
      return
    case .inspiration:
      await pause(0.6)
      withAnimation { viewModel.isTemplatePickerActive = true }
      return
    default:
      break
    }

    if self == .controls { return }
    viewModel.text = Self.sampleText
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
    case .colorPicker:
      viewModel.isBackgroundColorPickerActive = true
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

/// Every control group the button system touches, drawn on sky with nothing else around it.
struct ControlGallery: View {
  @StateObject private var viewModel = InstaThoughtViewModel(text: ScreenshotScene.sampleText, style: ScreenshotScene.sampleStyle)
  let group = ScreenshotScene.group

  var body: some View {
    ZStack {
      Cloud.sky.ignoresSafeArea()
      content
    }
    .statusBarHidden()
  }

  @ViewBuilder private var content: some View {
    switch group {
    case "font", "color", "layout", "presets":
      VStack {
        Spacer()
        StyleToolbar(viewModel: viewModel, activePanel: .constant(panel))
      }
    case "chips":
      VStack(alignment: .leading, spacing: 18) {
        chipRow(pressed: false)
        chipRow(pressed: true)
      }
    case "buttons":
      VStack(spacing: 22) {
        caption("Normal")
        buttonsBlock
        caption("Pressed")
        buttonsBlock.environment(\.cloudForcePressed, true)
        caption("Disabled")
        Button("Make it a page") {}.buttonStyle(CloudButtonStyle()).disabled(true)
      }
      .padding(.horizontal, 20)
    case "alert":
      CloudAlert(title: "Photos access is off",
                 message: "InstaThought needs permission to add images to Photos before it can save your pages.",
                 primary: ("Open Settings", {}), secondary: ("Not now", {}))
    case "swatches":
      VStack {
        Spacer()
        ColorPickerView(title: "Background", selected: Color.allColors[40], onColorSelected: { _ in })
          .frame(height: 480)
          .background(Cloud.white)
      }
    default:
      Text("Unknown group \(group)")
    }
  }

  private var panel: StylePanel {
    switch group {
    case "color": return .colors
    case "layout": return .layout
    case "presets": return .styles
    default: return .typography
    }
  }

  private func caption(_ text: String) -> some View {
    Text(text).font(Cloud.font(14, .bold)).foregroundStyle(Cloud.quiet).frame(maxWidth: .infinity, alignment: .leading)
  }

  private func chipRow(pressed: Bool) -> some View {
    VStack(alignment: .leading, spacing: 10) {
      caption(pressed ? "Pressed" : "Normal")
      HStack(spacing: 10) {
        Button {} label: { Label("Ideas", systemImage: "lightbulb") }.buttonStyle(CloudChipStyle())
        Button("Done") {}.buttonStyle(CloudChipStyle())
        Button("Preview") {}.buttonStyle(CloudChipStyle(fill: Cloud.sun, ink: Cloud.onSun))
      }
      HStack(spacing: 10) {
        Button {} label: { Label("All fonts", systemImage: "textformat") }.buttonStyle(CloudChipStyle())
        Button {} label: { Label("See all 33 presets", systemImage: "square.grid.3x3") }.buttonStyle(CloudChipStyle())
      }
    }
    .environment(\.cloudForcePressed, pressed)
    .padding(.horizontal, 20)
  }

  private var buttonsBlock: some View {
    VStack(spacing: 16) {
      Button("Make it a page") {}.buttonStyle(CloudButtonStyle())
      HStack(spacing: 12) {
        Button {} label: { Label("Share", systemImage: "square.and.arrow.up") }
          .buttonStyle(CloudButtonStyle(kind: .white)).frame(width: 132)
        Button {} label: { Label("Save to Photos", systemImage: "arrow.down.to.line") }
          .buttonStyle(CloudButtonStyle())
      }
    }
  }
}
#endif
