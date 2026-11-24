//
//  PreviewCarouselView.swift
//  InstaThought
//
//  Created by Joe Crozier on 3/17/25.
//

import Foundation
import UIKit
import SwiftUI

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

    @State private var currentPage: Int = 0

    var body: some View {
        VStack(spacing: 8) {
            if isRendering {
                Spacer()
                ProgressView()
                    .scaleEffect(1.2)
                Text("Generating...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
                Spacer()
            } else if previewViewModels.isEmpty {
                Spacer()
                Image(systemName: "doc.text")
                    .font(.system(size: 40))
                    .foregroundStyle(.tertiary)
                Text("No preview")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
            } else {
                // Preview pages
                TabView(selection: $currentPage) {
                    ForEach(Array(previewViewModels.enumerated()), id: \.element.id) { index, previewViewModel in
                        Image(uiImage: previewViewModel.image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .shadow(color: .black.opacity(0.15), radius: 12, y: 4)
                            .padding(.horizontal, 32)
                            .padding(.top, 24)
                            .padding(.bottom, 16)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Simple page dots
                if previewViewModels.count > 1 {
                    HStack(spacing: 6) {
                        ForEach(0..<previewViewModels.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? Theme.shared.colors.accentMedium : Color.gray.opacity(0.3))
                                .frame(width: 6, height: 6)
                        }
                    }
                    .padding(.bottom, 8)
                }
            }
        }
        .onChange(of: previewViewModels.count) { _, _ in
            currentPage = 0
        }
    }
}
