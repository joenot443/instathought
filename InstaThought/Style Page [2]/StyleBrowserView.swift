import SwiftUI

/// All presets, each rendered with your own text. The one in use has a sun ring.
struct StyleBrowserView: View {
  @Environment(\.dismiss) private var dismiss

  var styles: [Style]
  var text: String
  var selected: Style? = nil
  var onStyleSelected: (Style) -> Void

  private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack {
        Text("Presets").font(Cloud.font(28, .black))
        Spacer()
        Button("Done") { dismiss() }
          .buttonStyle(CloudChipStyle())
      }
      .foregroundStyle(Cloud.night)
      .padding(.horizontal, 20)
      .padding(.top, 22)
      .padding(.bottom, 14)

      ScrollView {
        LazyVGrid(columns: columns, spacing: 14) {
          ForEach(styles.indices, id: \.self) { index in
            PresetThumbnail(text: text, style: styles[index], isSelected: styles[index] === selected) {
              Cloud.tap()
              onStyleSelected(styles[index])
              dismiss()
            }
            .aspectRatio(0.8, contentMode: .fit)
          }
        }
        .padding(.horizontal, 17)
        .padding(.bottom, 24)
      }
    }
    .background(Cloud.sky.ignoresSafeArea())
    .presentationDragIndicator(.visible)
  }
}
