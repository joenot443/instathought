//
//  InstaThoughtViewModel.swift
//  InstaThought
//
//  Created by Joe Crozier on 3/22/25.
//

import Combine
import SwiftUI

class InstaThoughtViewModel: ObservableObject {
  @Published var hasLoaded: Bool = false
  @Published var previewViewModels: [PreviewViewModel]
  @Published var text: String
  @ObservedObject var style: Style
  @Published var isFontPickerActive: Bool = false
  @Published var isToastingCompletion: Bool = false
  @Published var saveAlert: SaveAlert?
  @Published var shouldNavigateToStyle: Bool = false
  @Published var shouldNavigateToPreview: Bool = false
  @Published var isTemplatePickerActive: Bool = false
  @Published var isStylePickerActive: Bool = false
  @Published var isColorPickerActive: Bool = false
  @Published var isBackgroundColorPickerActive: Bool = false
  
  private var cancellables: Set<AnyCancellable> = []
  @Published var isRenderingInProgress: Bool = false  // Flag to prevent multiple renderings at the same time
  private var currentRenderTask: Task<Void, Never>? // Add this property
  
  init(text: String, style: Style) {
    self.previewViewModels = RenderService.renderPreviews(text: text, style: style)
    self.text = text
    self.style = style
    
    requestPreviewRender()
    registerBindings()

    $text
      .dropFirst()
      .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
      .sink { DraftStore.saveText($0) }
      .store(in: &cancellables)
  }

  /// Starts from the thought and style the user left last time, if any.
  static func restored() -> InstaThoughtViewModel {
    InstaThoughtViewModel(text: DraftStore.loadText(), style: DraftStore.loadStyle() ?? .defaultStyle)
  }

  func saveDraft() {
    DraftStore.saveText(text)
    DraftStore.saveStyle(style)
  }

  /// Saves the rendered pages to Photos. Returns true only if they were actually saved;
  /// otherwise sets `saveAlert` so the preview screen can explain what went wrong.
  @MainActor
  func saveToPhotos() async -> Bool {
    switch await PhotoService.saveImages(images: previewViewModels.map { $0.image }) {
    case .saved:
      isToastingCompletion = true
      return true
    case .accessDenied:
      saveAlert = .photosAccessDenied
    case .failed:
      saveAlert = .saveFailed
    }
    return false
  }
  
  func registerBindings() {
    style.objectWillChange
      .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
      .sink { [weak self] style in
        self?.requestPreviewRender()
        self?.isRenderingInProgress = false
      }
      .store(in: &cancellables)
  }
  
  func requestPreviewRender() {
    // Cancel any existing render task
    currentRenderTask?.cancel()

    // Create new task
    currentRenderTask = Task { [weak self] in
      guard let self = self else { return }

      // Check for cancellation before proceeding
      if Task.isCancelled { return }

      await MainActor.run {
        self.previewViewModels = RenderService.renderPreviews(text: self.text, style: self.style)
        self.isRenderingInProgress = false
        DraftStore.saveStyle(self.style)
      }
    }
  }
  
  public static let defaultViewModel = InstaThoughtViewModel(text: .longNumbers, style: .defaultStyle)
}

enum SaveAlert: Identifiable {
  case photosAccessDenied
  case saveFailed

  var id: Self { self }
}
