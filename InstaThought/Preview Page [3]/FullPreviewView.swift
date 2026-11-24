import Foundation
import SwiftUI

struct FullPreviewView: View {
  @ObservedObject var viewModel: InstaThoughtViewModel
  @Environment(\.dismiss) var dismiss
  
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
        VStack {
          HStack {
            Spacer()
            // Save button
            Button(action: {
              PhotoService.saveImages(images: viewModel.previewViewModels.map { $0.image })
              viewModel.isToastingCompletion = true
              dismiss()
            }) {
              Text("Save")
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(viewModel.previewViewModels.first!.image.shouldUseWhiteText ? .white : Theme.shared.colors.accentText.opacity(0.8))
                .background(Color.white.opacity(0.2))
                .cornerRadius(8)
                .overlay(RoundedRectangle.init(cornerRadius: 8.0).fill(.clear).stroke(viewModel.previewViewModels.first!.image.shouldUseWhiteText ? .white.opacity(0.5) : Theme.shared.colors.accentText.opacity(0.5), style: .init(lineWidth: 1.0)))
                .padding(.horizontal)
            }
          }
        }
      }
    }
  }
}
