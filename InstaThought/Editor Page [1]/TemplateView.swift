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

        VStack(alignment: .leading, spacing: 1) {
          if let title = template.title {
            Text(title).font(Cloud.font(13, .black)).lineLimit(1)
          }
          if let author = template.author {
            Text(author).font(Cloud.font(12, .semibold)).foregroundStyle(Cloud.quiet).lineLimit(1)
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

  // `id` is generated locally, not read from samples.json.
  private enum CodingKeys: String, CodingKey {
    case author, title, content
  }

  static let samples: [Template] = {
    let jsonPath = Bundle.main.path(forResource: "samples", ofType: "json")!
    return try! JSONDecoder().decode([Template].self, from: Data(contentsOf: URL(fileURLWithPath: jsonPath))).shuffled()
  }()
  
}
