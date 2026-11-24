import SwiftUI

struct AccordionSection<Content: View>: View {
    let title: String
    let icon: String
    let iconColor: Color
    @Binding var isExpanded: Bool
    @ViewBuilder let content: () -> Content

    init(
        title: String,
        icon: String,
        iconColor: Color = Theme.shared.colors.accent,
        isExpanded: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.icon = icon
        self.iconColor = iconColor
        self._isExpanded = isExpanded
        self.content = content
    }

    var body: some View {
        HStack(spacing: 0) {
            // Colored accent bar on left
            RoundedRectangle(cornerRadius: 2)
                .fill(iconColor.gradient)
                .frame(width: 4)
                .padding(.vertical, 8)

            VStack(alignment: .leading, spacing: 0) {
                // Header
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isExpanded.toggle()
                    }
                }) {
                    HStack(spacing: 10) {
                        // Icon with colored background
                        Image(systemName: icon)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 28, height: 28)
                            .background(
                                RoundedRectangle(cornerRadius: 7)
                                    .fill(iconColor.gradient)
                                    .shadow(color: iconColor.opacity(0.3), radius: 4, y: 2)
                            )

                        Text(title)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(Theme.shared.colors.primaryText)

                        Spacer()

                        Image(systemName: "chevron.down")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Theme.shared.colors.tertiaryText)
                            .rotationEffect(.degrees(isExpanded ? 0 : -90))
                    }
                    .padding(.vertical, 14)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                // Content
                if isExpanded {
                    content()
                        .padding(.top, 2)
                        .padding(.bottom, 14)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(.leading, 12)
            .padding(.trailing, 16)
        }
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.black.opacity(0.04), lineWidth: 1)
        )
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var isExpanded = true
        @State var isCollapsed = false

        var body: some View {
            VStack(spacing: 12) {
                AccordionSection(
                    title: "Typography",
                    icon: "textformat",
                    iconColor: .blue,
                    isExpanded: $isExpanded
                ) {
                    Text("Content goes here")
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }

                AccordionSection(
                    title: "Colors",
                    icon: "paintpalette.fill",
                    iconColor: .purple,
                    isExpanded: $isCollapsed
                ) {
                    Text("More content")
                }
            }
            .padding()
        }
    }

    return PreviewWrapper()
}
