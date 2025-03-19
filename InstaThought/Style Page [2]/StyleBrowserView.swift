import SwiftUI

struct StyleBrowserView: View {
  @Environment(\.presentationMode) var presentationMode
  
  var styles: [Style]
  var text: String
  var onStyleSelected: (Style) -> Void
  
  private let columns = [GridItem(.flexible()), GridItem(.flexible())]
  
  var body: some View {
    ScrollView {
      LazyVGrid(columns: columns, spacing: 4.0) {
        ForEach(styles.indices, id: \.self) { index in
          Button(action: {
            onStyleSelected(styles[index])
            presentationMode.wrappedValue.dismiss()
          }) {
            RenderViewWrapper(text: text, style: styles[index].scaledTo(scale: 0.6))
              .tag(index)
              .frame(idealWidth: 300.0, idealHeight: 300.0)
          }
          .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .navigationTitle("Select a Style")
      }
    }
  }
}

