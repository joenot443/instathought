import SwiftUI

enum AdjusterMode {
  case continuous(range: ClosedRange<CGFloat>)
  case stepped(options: [CGFloat])
}

struct AdjusterView: View {
  let icon: String
  @Binding var value: CGFloat
  let mode: AdjusterMode
  let rotation: Double
  
  init(icon: String, value: Binding<CGFloat>, mode: AdjusterMode, rotation: Double = 0.0, scale: CGFloat = 1.0, minusButtonScale: CGFloat = 1.0, plusButtonScale: CGFloat = 1.0) {
    self.icon = icon
    self._value = value
    self.mode = mode
    self.rotation = rotation
    self.scale = scale
    self.minusButtonScale = minusButtonScale
    self.plusButtonScale = plusButtonScale
  }
  
  @State private var scale: CGFloat
  @State private var minusButtonScale: CGFloat
  @State private var plusButtonScale: CGFloat
  
  private let ButtonSize = 36.0
  
  var body: some View {
    HStack(spacing: 12) {
      Button {
        decrementValue()
      } label: {
        Image(systemName: "minus")
          .renderingMode(.template)
          .foregroundStyle(Theme.shared.colors.primaryButtonText)
          .frame(height: ButtonSize)
      }
      .frame(width: ButtonSize, height: ButtonSize)
      .background(Theme.shared.colors.accent)
      .clipShape(RoundedRectangle(cornerRadius: 8))
      .overlay {
        RoundedRectangle(cornerRadius: 8.0).fill(.clear).stroke(Theme.shared.colors.accentStroke, style: .init(lineWidth: 0.5))
      }
      .scaleEffect(minusButtonScale)
      .animation(.spring(response: 0.2, dampingFraction: 0.6), value: minusButtonScale)
      .pressEvents {
        withAnimation { minusButtonScale = 0.8 }
      } onRelease: {
        withAnimation { minusButtonScale = 1.0 }
      }
      
      VStack(spacing: 0) {
        Image(systemName: icon)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .font(.title2)
          .rotationEffect(.degrees(rotation))
          .foregroundStyle(Theme.shared.colors.accentText.opacity(0.7))
          .scaleEffect(scale)
          .animation(.spring(response: 0.2, dampingFraction: 0.6), value: scale)
          .padding(.top, 4.0)
        Spacer(minLength: 0.0)
        Text(value.truncatingRemainder(dividingBy: 1) == 0
             ? String(format: "%.0f", value)
             : String(format: "%.1f", value))
        	.font(.system(size: 10.0, weight: .bold))
          .lineLimit(1)
          .foregroundStyle(Theme.shared.colors.accentText)
          .animation(.spring(response: 0.3, dampingFraction: 0.5), value: value.description)
          .padding(.vertical, 2.0)
      }
      .frame(width: 26)
      
      Button {
        incrementValue()
      } label: {
        Image(systemName: "plus")
          .renderingMode(.template)
          .foregroundStyle(Theme.shared.colors.primaryButtonText)
      }
      .background(Theme.shared.colors.accent)
      .frame(width: ButtonSize, height: ButtonSize)
      .background(Theme.shared.colors.accent)
      .clipShape(RoundedRectangle(cornerRadius: 8))
      .overlay {
        RoundedRectangle(cornerRadius: 8.0).fill(.clear).stroke(Theme.shared.colors.accentStroke, style: .init(lineWidth: 0.5))
      }
      .scaleEffect(plusButtonScale)
      .animation(.spring(response: 0.2, dampingFraction: 0.6), value: plusButtonScale)
      .pressEvents {
        withAnimation { plusButtonScale = 0.8 }
      } onRelease: {
        withAnimation { plusButtonScale = 1.0 }
      }
    }
    .padding(0)
    .frame(height: ButtonSize)
    .background(Theme.shared.colors.accentBackground)
    .clipShape(RoundedRectangle(cornerRadius: 8))

  }
  
  private func decrementValue() {
    switch mode {
    case .continuous(let range):
      value = (max(range.lowerBound, value - 1))
      triggerAnimation(direction: .shrink)
    case .stepped(let options):
      if let idx = options.firstIndex(where: { $0.description == value.description }), idx > 0 {
        value = options[idx - 1]
        triggerAnimation(direction: .shrink)
      }
    }
  }
  
  private func incrementValue() {
    switch mode {
    case .continuous(let range):
      value = (min(range.upperBound, value + 1))
      triggerAnimation(direction: .grow)
    case .stepped(let options):
      if let idx = options.firstIndex(where: { $0.description == value.description }), idx < options.count - 1 {
        value = options[idx + 1]
        triggerAnimation(direction: .grow)
      }
    }
  }
  
  private enum Direction { case grow, shrink }
  
  private func triggerAnimation(direction: Direction) {
    scale = (direction == .grow) ? 1.15 : 0.85
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
      scale = 1.0
    }
  }
}

extension View {
  func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
    self.simultaneousGesture(
      DragGesture(minimumDistance: 0)
        .onChanged { _ in
          onPress()
        }
        .onEnded { _ in
          onRelease()
        }
    )
  }
}
//
//#Preview("Continuous Adjuster") {
//  HStack {
//    AdjusterView(
//      icon: "textformat.size",
//      value: 16.0,
//      mode: .continuous(range: 8...32)
//    )
//    .padding()
//    PrimaryButton(title: "Continue", action: {})
//  }
//}

