import SwiftUI

enum StylePanel: String, CaseIterable {
    case none
    case typography
    case colors
    case layout
    case styles

    var icon: String {
        switch self {
        case .none: return ""
        case .typography: return "textformat.size"
        case .colors: return "paintpalette"
        case .layout: return "rectangle.split.3x1"
        case .styles: return "sparkles"
        }
    }

    var label: String {
        switch self {
        case .none: return ""
        case .typography: return "Text"
        case .colors: return "Color"
        case .layout: return "Layout"
        case .styles: return "Styles"
        }
    }
}

struct StyleToolbar: View {
    @ObservedObject var viewModel: InstaThoughtViewModel
    @Binding var activePanel: StylePanel

    var body: some View {
        VStack(spacing: 0) {
            // Divider when panel is open
            if activePanel != .none {
                Divider()
            }

            // Expanded panel content
            if activePanel != .none {
                panelContent
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            Divider()

            // Toolbar
            HStack(spacing: 0) {
                ForEach([StylePanel.typography, .colors, .layout, .styles], id: \.self) { panel in
                    ToolbarButton(
                        icon: panel.icon,
                        label: panel.label,
                        isActive: activePanel == panel
                    ) {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                            activePanel = activePanel == panel ? .none : panel
                        }
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
        }
        .background(Color(UIColor.systemBackground))
    }

    @ViewBuilder
    private var panelContent: some View {
        switch activePanel {
        case .none:
            EmptyView()

        case .typography:
            TypographyPanel(viewModel: viewModel)

        case .colors:
            ColorsPanel(viewModel: viewModel)

        case .layout:
            LayoutPanel(viewModel: viewModel)

        case .styles:
            StylesPanel(viewModel: viewModel)
        }
    }
}

// MARK: - Toolbar Button

struct ToolbarButton: View {
    let icon: String
    let label: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            action()
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: isActive ? .semibold : .regular))
                    .symbolEffect(.bounce, value: isActive)
                Text(label)
                    .font(.caption2)
                    .fontWeight(isActive ? .medium : .regular)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .foregroundStyle(isActive ? Theme.shared.colors.accentMedium : Theme.shared.colors.secondaryText)
            .overlay(alignment: .bottom) {
                if isActive {
                    Capsule()
                        .fill(Theme.shared.colors.accentMedium)
                        .frame(width: 24, height: 3)
                        .offset(y: 4)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Typography Panel

struct TypographyPanel: View {
    @ObservedObject var viewModel: InstaThoughtViewModel

    var body: some View {
        VStack(spacing: 14) {
            // Font picker button - shows font in its own typeface
            Button {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                viewModel.isFontPickerActive = true
            } label: {
                HStack {
                    Text(viewModel.style.fontName)
                        .font(.custom(viewModel.style.fontName, size: 17))
                        .lineLimit(1)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.tertiary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 13)
                .background(Color(UIColor.tertiarySystemBackground))
                .cornerRadius(10)
            }
            .buttonStyle(StepperButtonStyle())
            .foregroundStyle(Theme.shared.colors.primaryText)

            // Size, Alignment, Line Height - all in one row
            HStack(spacing: 12) {
                CompactStepper(
                    value: $viewModel.style.fontSize,
                    range: 8...100,
                    label: "Size"
                )

                Divider()
                    .frame(height: 36)

                AlignmentPicker(selection: $viewModel.style.textAlignment)

                Divider()
                    .frame(height: 36)

                CompactStepper(
                    value: $viewModel.style.lineHeight,
                    options: Style.defaultLineHeights,
                    label: "Spacing"
                )
            }
        }
    }
}

// MARK: - Colors Panel

struct ColorsPanel: View {
    @ObservedObject var viewModel: InstaThoughtViewModel

    var body: some View {
        VStack(spacing: 10) {
            ColorRow(
                label: "Text",
                color: viewModel.style.foregroundColor,
                isPresented: $viewModel.isColorPickerActive
            ) { color in
                viewModel.style.foregroundColor = color
            }

            ColorRow(
                label: "Background",
                color: viewModel.style.backgroundColor,
                isPresented: $viewModel.isBackgroundColorPickerActive
            ) { color in
                viewModel.style.backgroundColor = color
            }
        }
    }
}

struct ColorRow: View {
    let label: String
    let color: Color
    @Binding var isPresented: Bool
    let onColorSelected: (Color) -> Void

    var body: some View {
        Button {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            isPresented = true
        } label: {
            HStack {
                Text(label)
                    .font(.system(size: 15))
                    .foregroundStyle(Theme.shared.colors.primaryText)

                Spacer()

                RoundedRectangle(cornerRadius: 6)
                    .fill(color)
                    .frame(width: 28, height: 28)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.primary.opacity(0.15), lineWidth: 1)
                    )

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(Color(UIColor.tertiarySystemBackground))
            .cornerRadius(10)
            .contentShape(Rectangle())
        }
        .buttonStyle(StepperButtonStyle())
        .popover(isPresented: $isPresented) {
            ColorPickerView(onColorSelected: onColorSelected)
                .presentationCompactAdaptation(.sheet)
                .presentationDetents([.fraction(0.35)])
        }
    }
}

// MARK: - Layout Panel

struct LayoutPanel: View {
    @ObservedObject var viewModel: InstaThoughtViewModel

    var body: some View {
        VStack(spacing: 14) {
            // Shape picker
            ShapePicker(selection: $viewModel.style.shape)

            // Padding section
            VStack(spacing: 8) {
                Text("Padding")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 24) {
                    CompactStepper(
                        value: $viewModel.style.verticalPadding,
                        options: Style.defaultPaddings,
                        label: "Vertical"
                    )

                    Divider()
                        .frame(height: 36)

                    CompactStepper(
                        value: $viewModel.style.padding,
                        options: Style.defaultPaddings,
                        label: "Horizontal"
                    )
                }
            }
        }
    }
}

struct ShapePicker: View {
    @Binding var selection: Shape

    private var selectedIndex: Int {
        Shape.allCases.firstIndex(of: selection) ?? 0
    }

    var body: some View {
        GeometryReader { geo in
            let itemWidth = (geo.size.width - 8) / CGFloat(Shape.allCases.count)

            ZStack(alignment: .leading) {
                // Sliding background
                RoundedRectangle(cornerRadius: 8)
                    .fill(Theme.shared.colors.accent)
                    .frame(width: itemWidth - 4, height: geo.size.height - 8)
                    .offset(x: CGFloat(selectedIndex) * itemWidth + 4, y: 4)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedIndex)

                // Buttons
                HStack(spacing: 0) {
                    ForEach(Array(Shape.allCases.enumerated()), id: \.element) { index, shape in
                        Button {
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                            selection = shape
                        } label: {
                            VStack(spacing: 6) {
                                Image(systemName: shape.icon())
                                    .font(.system(size: 20))
                                Text(shape.name())
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .foregroundStyle(selection == shape ? Theme.shared.colors.primaryButtonText : Theme.shared.colors.secondaryText)
                            .animation(.easeInOut(duration: 0.2), value: selection)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .frame(height: 64)
        .background(Color(UIColor.tertiarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Styles Panel

struct StylesPanel: View {
    @ObservedObject var viewModel: InstaThoughtViewModel

    var body: some View {
        Button {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            viewModel.isStylePickerActive = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "square.grid.2x2")
                    .font(.system(size: 18))
                    .foregroundStyle(Theme.shared.colors.accentMedium)
                Text("Browse Style Presets")
                    .font(.system(size: 15, weight: .medium))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .background(Color(UIColor.tertiarySystemBackground))
            .cornerRadius(10)
        }
        .buttonStyle(StepperButtonStyle())
        .foregroundStyle(Theme.shared.colors.primaryText)
    }
}

// MARK: - Alignment Picker

struct AlignmentPicker: View {
    @Binding var selection: TextAlignmentOption

    var body: some View {
        VStack(spacing: 6) {
            Text("Align")
                .font(.caption2)
                .foregroundStyle(.secondary)

            HStack(spacing: 2) {
                ForEach(TextAlignmentOption.allCases, id: \.self) { alignment in
                    Button {
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selection = alignment
                        }
                    } label: {
                        alignment.icon()
                            .font(.system(size: 13))
                            .frame(width: 30, height: 30)
                            .background(selection == alignment ? Theme.shared.colors.accentMedium : Color.clear)
                            .foregroundStyle(selection == alignment ? .white : Theme.shared.colors.secondaryText)
                            .cornerRadius(6)
                    }
                    .buttonStyle(StepperButtonStyle())
                }
            }
            .padding(2)
            .background(Color(UIColor.tertiarySystemBackground))
            .cornerRadius(9)
        }
    }
}

// MARK: - Compact Stepper

struct CompactStepper: View {
    @Binding var value: CGFloat
    var range: ClosedRange<CGFloat>?
    var options: [CGFloat]?
    let label: String

    init(value: Binding<CGFloat>, range: ClosedRange<CGFloat>, label: String) {
        self._value = value
        self.range = range
        self.options = nil
        self.label = label
    }

    init(value: Binding<CGFloat>, options: [CGFloat], label: String) {
        self._value = value
        self.range = nil
        self.options = options
        self.label = label
    }

    var body: some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)

            HStack(spacing: 0) {
                Button {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    withAnimation(.easeInOut(duration: 0.15)) {
                        decrement()
                    }
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 12, weight: .semibold))
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(StepperButtonStyle())

                Text(formatValue())
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .frame(minWidth: 28)
                    .contentTransition(.numericText())

                Button {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    withAnimation(.easeInOut(duration: 0.15)) {
                        increment()
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .semibold))
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(StepperButtonStyle())
            }
            .foregroundStyle(Theme.shared.colors.primaryText)
            .background(Color(UIColor.tertiarySystemBackground))
            .cornerRadius(8)
        }
    }

    private func formatValue() -> String {
        if value == floor(value) {
            return String(format: "%.0f", value)
        } else {
            return String(format: "%.1f", value)
        }
    }

    private func increment() {
        if let options = options {
            if let idx = options.firstIndex(of: value), idx < options.count - 1 {
                value = options[idx + 1]
            }
        } else if let range = range {
            value = min(value + 1, range.upperBound)
        }
    }

    private func decrement() {
        if let options = options {
            if let idx = options.firstIndex(of: value), idx > 0 {
                value = options[idx - 1]
            }
        } else if let range = range {
            value = max(value - 1, range.lowerBound)
        }
    }
}

// MARK: - Button Styles

struct StepperButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
