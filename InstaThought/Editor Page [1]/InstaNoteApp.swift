//
//  InstaThoughtApp.swift
//  InstaThought
//
//  Created by Joe Crozier on 9/4/24.
//

import SwiftUI
import AlertToast
import FontPicker
import Combine

// App entry point
@main
struct InstaThoughtApp: App {
  @StateObject private var theme: Theme = Theme.shared
  
  var body: some Scene {
    WindowGroup {
      InstaThoughtView(viewModel: InstaThoughtViewModel(text: "", style: .defaultStyle))
        .environmentObject(theme)
    }
  }
}

#Preview {
  return InstaThoughtView(viewModel: InstaThoughtViewModel(text: "AAA", style: .init(foregroundColor: .black, backgroundColor: .white, fontSize: 12.0)))
}
