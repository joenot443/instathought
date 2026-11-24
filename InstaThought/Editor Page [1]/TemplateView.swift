//
//  TemplateView.swift
//  InstaThought
//
//  Created by Joe Crozier on 3/17/25.
//

import Foundation
import SwiftUI



struct TemplateView: View {
  @Binding var selectedText: String
  @Environment(\.colorScheme) var colorScheme
  @ObservedObject var viewModel: InstaThoughtViewModel

  let onSelect: (Template) -> Void
  let onHeaderTap: () -> Void

  var body: some View {
    VStack(spacing: 0) {
      // Header
      Button(action: {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
          viewModel.isTemplatePickerActive.toggle()
          onHeaderTap()
        }
      }) {
        HStack {
          Image(systemName: "lightbulb")
            .font(.system(size: 14))
            .foregroundStyle(Theme.shared.colors.accentMedium)
          Text("Need inspiration?")
            .foregroundStyle(.secondary)
            .font(.subheadline)
            .fontWeight(.medium)
          Spacer()
          Image(systemName: "chevron.down")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.tertiary)
            .rotationEffect(.degrees(viewModel.isTemplatePickerActive ? 0 : -90))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
      }
      .buttonStyle(.plain)

      // Templates Grid
      if viewModel.isTemplatePickerActive {
        ScrollView(.vertical, showsIndicators: false) {
          LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(Template.samples) { template in
              TemplateCard(template: template) {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                  viewModel.isTemplatePickerActive = false
                  onHeaderTap()
                  onSelect(template)
                }
              }
            }
          }
          .padding(.horizontal, 20)
          .padding(.bottom, 16)
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
      }
    }
    .frame(maxWidth: .infinity)
    .background(Color(UIColor.systemBackground))
    .clipped()
    .shadow(color: colorScheme == .dark ? .white.opacity(0.03) : .black.opacity(0.08),
            radius: 8, y: -4)
    .contentShape(Rectangle())
  }
}

struct TemplateCard: View {
  let template: Template
  let onSelect: () -> Void
  @State private var isPressed = false

  var body: some View {
    Button(action: onSelect) {
      VStack(alignment: .leading, spacing: 8) {
        // Preview text
        Text(template.content)
          .font(.system(size: 13, weight: .regular))
          .foregroundStyle(.primary.opacity(0.8))
          .lineLimit(5)
          .multilineTextAlignment(.leading)
          .frame(maxWidth: .infinity, alignment: .leading)

        Spacer(minLength: 0)

        // Title and author
        if template.title != nil || template.author != nil {
          VStack(alignment: .leading, spacing: 2) {
            if let title = template.title {
              Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)
            }
            if let author = template.author {
              Text(author)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .lineLimit(1)
            }
          }
        }
      }
      .padding(12)
      .frame(maxWidth: .infinity, minHeight: 140, alignment: .topLeading)
      .background(Color(UIColor.secondarySystemBackground))
      .cornerRadius(12)
      .overlay(
        RoundedRectangle(cornerRadius: 12)
          .stroke(Color.primary.opacity(0.06), lineWidth: 1)
      )
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
  let id: UUID = UUID()
  let author: String?
  let title: String?
  let content: String
  
  static let samples: [Template] = {
    let jsonPath = Bundle.main.path(forResource: "samples", ofType: "json")!
    return try! JSONDecoder().decode([Template].self, from: Data(contentsOf: URL(fileURLWithPath: jsonPath))).shuffled()
  }()
  
}
