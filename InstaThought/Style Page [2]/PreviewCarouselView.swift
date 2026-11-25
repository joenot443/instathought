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
      if isRendering || previewViewModels.isEmpty {
        Spacer()
        ProgressView().tint(Cloud.night).scaleEffect(1.2)
        Text("Making your pages…")
          .font(Cloud.font(15, .bold))
          .foregroundStyle(Cloud.quiet)
          .padding(.top, 8)
        Spacer()
      } else {
        TabView(selection: $currentPage) {
          ForEach(Array(previewViewModels.enumerated()), id: \.element.id) { index, previewViewModel in
            CloudPage(image: previewViewModel.image)
              .padding(.horizontal, 40)
              .padding(.top, 14)
              .padding(.bottom, 20)
              .tag(index)
          }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))

        if previewViewModels.count > 1 {
          CloudPageDots(count: previewViewModels.count, current: currentPage)
            .padding(.bottom, 12)
        }
      }
    }
    .onChange(of: previewViewModels.count) { _, _ in
      currentPage = 0
    }
  }
}

/// A rendered page with a drawn outline and a solid navy edge, floating on sky.
struct CloudPage: View {
  let image: UIImage
  var radius: CGFloat = 18

  var body: some View {
    Image(uiImage: image)
      .resizable()
      .aspectRatio(contentMode: .fit)
      .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
      .overlay(RoundedRectangle(cornerRadius: radius, style: .continuous).strokeBorder(Cloud.night, lineWidth: Cloud.line))
      .cloudEdge(radius: radius, depth: 6)
      .accessibilityLabel("Page preview")
  }
}

struct CloudPageDots: View {
  let count: Int
  let current: Int

  var body: some View {
    HStack(spacing: 6) {
      ForEach(0..<count, id: \.self) { index in
        Capsule()
          .fill(index == current ? Cloud.night : Cloud.soft)
          .frame(width: index == current ? 18 : 7, height: 7)
      }
    }
    .animation(.snappy(duration: 0.2), value: current)
    .accessibilityElement()
    .accessibilityLabel("Page \(current + 1) of \(count)")
  }
}
