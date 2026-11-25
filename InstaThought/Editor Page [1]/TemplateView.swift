//
//  TemplateView.swift
//  InstaThought
//
//  Created by Joe Crozier on 3/17/25.
//

import Foundation
import SwiftUI



/// "Need inspiration?": passages from the bundled books and poems to start from.
struct InspirationSheet: View {
  let onSelect: (Template) -> Void
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack {
        Text("Need inspiration?")
          .font(Cloud.font(28, .black))
          .foregroundStyle(Cloud.night)
        Spacer()
        Button("Close") { dismiss() }
          .buttonStyle(CloudChipStyle())
      }
      .padding(.horizontal, 20)
      .padding(.top, 22)
      .padding(.bottom, 14)

      ScrollView(.vertical, showsIndicators: false) {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
          ForEach(Template.samples) { template in
            TemplateCard(template: template) {
              Cloud.tap()
              onSelect(template)
              dismiss()
            }
          }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
      }
    }
    .background(Cloud.sky.ignoresSafeArea())
    .presentationDragIndicator(.visible)
  }
}

struct TemplateCard: View {
  let template: Template
  let onSelect: () -> Void

  var body: some View {
    Button(action: onSelect) {
      VStack(alignment: .leading, spacing: 10) {
        Text(template.content)
          .font(.custom("Lora-Regular", size: 14))
          .lineSpacing(2)
          .lineLimit(6)
          .multilineTextAlignment(.leading)
          .frame(maxWidth: .infinity, alignment: .leading)

        Spacer(minLength: 0)

        HStack(alignment: .bottom, spacing: 8) {
          VStack(alignment: .leading, spacing: 1) {
            if let title = template.title {
              Text(title).font(Cloud.font(13, .black)).lineLimit(1)
            }
            if let author = template.author {
              Text(author).font(Cloud.font(12, .semibold)).foregroundStyle(Cloud.quiet).lineLimit(1)
            }
          }
          Spacer(minLength: 0)
          if let look = template.look {
            // The look the sample opens in: its font, on its colours.
            Text("Aa")
              .font(.custom(look.fontName, size: 13))
              .foregroundStyle(look.foregroundColor)
              .frame(width: 30, height: 30)
              .background(Circle().fill(look.backgroundColor))
              .overlay(Circle().strokeBorder(Cloud.stroke, lineWidth: 1.5))
              .accessibilityHidden(true)
          }
        }
      }
      .foregroundStyle(Cloud.night)
      .padding(14)
      .frame(maxWidth: .infinity, minHeight: 178, alignment: .topLeading)
      .cloudOutlined(radius: 26)
      .contentShape(Rectangle())
    }
    .buttonStyle(TemplateCardButtonStyle())
  }
}

extension Template {
  var look: Style? { style?.makeStyle() }
}

struct TemplateCardButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
      .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
  }
}



struct Template: Codable, Identifiable {
  var id = UUID()
  let author: String?
  let title: String?
  let content: String
  /// The look the sample opens in: one of the bundled presets, optionally resized or realigned.
  let style: SampleStyle?

  // `id` is generated locally, not read from samples.json.
  private enum CodingKeys: String, CodingKey {
    case author, title, content, style
  }

  static let samples: [Template] = {
    let jsonPath = Bundle.main.path(forResource: "samples", ofType: "json")!
    return try! JSONDecoder().decode([Template].self, from: Data(contentsOf: URL(fileURLWithPath: jsonPath))).shuffled()
  }()
}

struct SampleStyle: Codable {
  /// Index into `Style.defaultStyles`.
  let preset: Int
  var size: CGFloat?
  var lineHeight: CGFloat?
  /// "left", "center", "right" or "justified".
  var align: String?

  /// A fresh copy of the preset with the overrides applied, so editing it never changes the preset.
  func makeStyle() -> Style? {
    guard Style.defaultStyles.indices.contains(preset) else { return nil }
    let base = Style.defaultStyles[preset]
    let style = Style(foregroundColor: base.foregroundColor, backgroundColor: base.backgroundColor,
                      fontSize: size ?? base.fontSize, padding: base.padding, verticalPadding: base.verticalPadding,
                      lineHeight: lineHeight ?? base.lineHeight, fontName: base.fontName, shape: base.shape)
    // Style.init always starts left-aligned, so set alignment afterwards.
    style.textAlignment = TextAlignmentOption.allCases.first { String(describing: $0) == align } ?? base.textAlignment
    return style
  }
}
