import SwiftUI

struct StyleBrowserView: View {
  @Environment(\.presentationMode) var presentationMode
  
  var styles: [Style]
  var text: String
  var onStyleSelected: (Style) -> Void
  
  private let columns = [GridItem(.flexible()), GridItem(.flexible())]
  
  var body: some View {
    ScrollView {
      LazyVGrid(columns: columns, spacing: 10.0) {
        ForEach(styles.indices, id: \.self) { index in
          RenderViewWrapper(text: text, style: styles[index].browserStyle) {
            onStyleSelected(styles[index])
            presentationMode.wrappedValue.dismiss()
          }.aspectRatio(1.3, contentMode: .fit)
        }
      }
      .padding()
      .navigationTitle("Select a Style")
    }
  }
}

