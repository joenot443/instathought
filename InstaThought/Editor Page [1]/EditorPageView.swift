//
//  EditorPageView.swift
//  InstaThought
//
//  Created by Joe Crozier on 3/17/25.
//

import SwiftUI
import AlertToast
import Combine

struct TextEditorPage: View {
  @ObservedObject var viewModel: InstaThoughtViewModel
  @State private var isTemplateCollapsed = true
  @FocusState private var isEditorFocused: Bool
  
  var body: some View {
    ZStack(alignment: .bottom) {
      VStack {
        VStack {
          TextEditorView(text: $viewModel.text) {}
            .focused($isEditorFocused)
            .onChange(of: isEditorFocused) { newValue, _ in
              if newValue {
                withAnimation(.spring()) {
                  isTemplateCollapsed = true
                }
              }
            }
            .onChange(of: viewModel.text) { newText, _ in
              
            }
            .onTapGesture {
              isTemplateCollapsed = true
            }
          Spacer()
        }
        
        if !viewModel.text.isEmpty {
          Spacer()
          PrimaryButton(title: "Next") {
            viewModel.requestPreviewRender()
            viewModel.shouldNavigateToPreview = true
          }
        }
      }
    }
    
    // Template view
    TemplateView(selectedText: $viewModel.text, isCollapsed: $isTemplateCollapsed)
      .onChange(of: viewModel.text) { newValue, _ in
        if !newValue.isEmpty && !isTemplateCollapsed {
          withAnimation(.spring()) {
            isTemplateCollapsed = true
          }
        }
      }
      .onAppear {
        isTemplateCollapsed = viewModel.text.isEmpty
      }
      .navigationTitle("Your Thoughts")
      .animation(.spring(), value: viewModel.text.isEmpty)
  }
}

struct InstaThoughtView: View {
  @StateObject var viewModel: InstaThoughtViewModel
  
  var body: some View {
    NavigationStack {
      TextEditorPage(viewModel: viewModel)
        .navigationDestination(isPresented: $viewModel.shouldNavigateToPreview) {
          StyleAndPreviewPage(viewModel: viewModel)
        }
    }
  }
}

class InstaThoughtViewModel: ObservableObject {
  @Published var previewViewModels: [PreviewViewModel]
  @Published var text: String
  @ObservedObject var style: Style
  @Published var isKeyboardVisible: Bool = false // Track keyboard visibility
  @Published var isFontPickerActive: Bool = false
  @Published var isToastingCompletion: Bool = false
  @Published var shouldNavigateToPreview: Bool = false
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
    
    NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
      .sink { [weak self] _ in
        self?.isKeyboardVisible = true
      }
      .store(in: &cancellables)
    
    NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
      .sink { [weak self] _ in
        self?.isKeyboardVisible = false
      }
      .store(in: &cancellables)
    
    requestPreviewRender()
    registerBindings()
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
      }
    }
  }
  
  public static let defaultViewModel = InstaThoughtViewModel(text: .longNumbers, style: .defaultStyle)
}

