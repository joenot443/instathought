//
//  IntroView.swift
//  InstaThought
//
//  Created by Joe Crozier on 3/22/25.
//

import Foundation
import SwiftUI

struct IntroView: View {
  @State private var scale: CGFloat = 0.8666
  var onAnimationComplete: (() -> Void)? = nil
  @State private var offset: CGFloat = 0
  
  var body: some View {
    ZStack {
      Theme.shared.colors.accentBackground
        .ignoresSafeArea()
      
      Image("icon_1024")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(maxWidth: .infinity)
        .scaleEffect(scale)
        .onAppear {
          withAnimation(.easeInOut(duration: 5.0)) {
            scale = 20.0
            offset = 0
          } completion: {
            onAnimationComplete?()
          }
        }
        .padding(.top, offset)
    }.background(Theme.shared.colors.accent)
  }
}
