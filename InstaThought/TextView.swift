//
//  InstaThoughtView.swift
//  InstaThought
//
//  Created by Joe Crozier on 9/4/24.
//
import Combine
import SwiftUI

class InstaThoughtViewModel: ObservableObject {
  @Published var previewViewModels: [PreviewViewModel]
  @Published var text: String
  @ObservedObject var style: Style
  @Published var isKeyboardVisible: Bool = false // Track keyboard visibility
  @Published var isFontPickerActive: Bool = false
  @Published var isToastingCompletion: Bool = false
  var defaultStyles: [Style]
  
  private var cancellables: Set<AnyCancellable> = []
  @Published var isRenderingInProgress: Bool = false  // Flag to prevent multiple renderings at the same time
  
  init(text: String, style: Style, defaultStyles: [Style]) {
    self.previewViewModels = RenderService.renderPreviews(text: text, style: style)
    self.defaultStyles = defaultStyles
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
    // Combine text and style changes into a single pipeline with debouncing
    style.objectWillChange
      .debounce(for: .milliseconds(300), scheduler: RunLoop.main) // Debounce to avoid frequent re-renders during typing
      .sink { [weak self] style in
        self?.requestPreviewRender()
        self?.isRenderingInProgress = false
      }
      .store(in: &cancellables)
  }
  
  func requestPreviewRender() {
    // Prevent overlapping render tasks
    guard !isRenderingInProgress else { return }
    
    isRenderingInProgress = true
    
    // Ensure rendering happens on the main thread
    DispatchQueue.main.asyncAfter(deadline: .now() + .microseconds(500)) { [weak self] in
      guard let self = self else { return }
      self.previewViewModels = RenderService.renderPreviews(text: text, style: self.style)
      self.isRenderingInProgress = false  // Mark rendering as complete
    }
  }
  
  public static let defaultViewModel = InstaThoughtViewModel(text: .longNumbers, style: .defaultStyle, defaultStyles: Style.defaultStyles)
}


class PreviewViewModel: Identifiable {
  let image: UIImage
  let text: String
  internal let id: UUID
  
  init(image: UIImage, text: String) {
    self.text = text
    self.image = image
    self.id = UUID()
  }
}

struct PreviewCarouselView: View {
  @Binding var isRendering: Bool
  var previewViewModels: [PreviewViewModel]
  
  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack {
        if (isRendering) {
          ProgressView("Generating preview...")
        } else {
          ForEach(previewViewModels) { previewViewModel in
            Image(uiImage: previewViewModel.image)
              .resizable()
              .aspectRatio(contentMode: .fill)
              .cornerRadius(8.0)
              .frame(maxHeight: .infinity)
          }
        }
      }
      .padding(.horizontal)
      .padding(.vertical)
    }
    .background(Color.gray.opacity(0.1))
    .cornerRadius(8)
    .padding(.horizontal)
  }
}
struct TextEditorView: View {
  @Binding var text: String
  @FocusState private var isFocused: Bool
  @Environment(\.colorScheme) private var colorScheme
  let action: () -> Void
  
  var body: some View {
    VStack(spacing: 15) {
      ZStack(alignment: .leading) {
        if text.isEmpty {
          VStack {
            Text("What's on your mind?\n\nYou can start a new line with @ for a new page.")
              .padding()
              .font(.custom("Helvetica", size: 24))
              .foregroundStyle(colorScheme == .dark ? .white.opacity(0.4) : .secondary.opacity(0.4))
              .padding(.horizontal)
            Spacer()
          }
        }
        
        TextEditor(text: $text)
          .font(.custom("Helvetica", size: 24))
          .focused($isFocused)
          .tint(colorScheme == .dark ? .white : .blue)
          .cornerRadius(8)
          .opacity(text.isEmpty ? 0.25 : 1)
          .padding(.horizontal)
          .contentMargins(8.0)
      }
    }
  }
}

struct PreviewButtonsView: View {
  @ObservedObject var viewModel: InstaThoughtViewModel
  
  var body: some View {
    VStack {
      HStack {
        Spacer()
        // Preview button
        NavigationLink(destination: FullPreviewView(viewModel: viewModel)) {
          Text("Preview")
            .frame(maxWidth: .infinity)
            .fontWeight(.bold)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        
        Spacer()
      }
    }
  }
}

#Preview {
  return InstaThoughtView(viewModel: InstaThoughtViewModel(text: "", style: .init(foregroundColor: .black, backgroundColor: .white, fontSize: 12.0), defaultStyles: [Style(foregroundColor: .white, backgroundColor: .black, fontSize: 24)]))
}
