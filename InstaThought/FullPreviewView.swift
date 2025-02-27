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
                .fontWeight(.bold)
                .padding()
                .foregroundColor(viewModel.previewViewModels.first!.image.shouldUseWhiteText ? .white : .black)
                .background(Color.white.opacity(0.2)) // Simulate transparency
                .cornerRadius(8)
                .padding(.horizontal)
            }
          }
        }
      }
    }
  }
}
