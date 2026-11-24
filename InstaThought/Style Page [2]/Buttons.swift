import SwiftUI

fileprivate let ButtonHeight = 36.0

struct ActionButton: View {
  let icon: Image
  let label: String
  let spacers: Bool
  let action: () -> Void
  
  private let ButtonHeight = 36.0
  
  init(icon: Image, label: String, spacers: Bool = true, action: @escaping () -> Void) {
    self.icon = icon
    self.label = label
    self.action = action
    self.spacers = spacers
  }
  
  init(icon: String, label: String, spacers: Bool = true, action: @escaping () -> Void) {
    self.icon = Image(systemName: icon)
    self.label = label
    self.action = action
    self.spacers = spacers
  }
  
  @State private var buttonScale: CGFloat = 1.0
  
  var body: some View {
      HStack {
        if spacers {  
          Spacer()
        }
        icon.foregroundStyle(Theme.shared.colors.accentText)
        Text(label).foregroundStyle(Theme.shared.colors.accentText)
        if spacers {
          Spacer()
        }
    	}
    .padding(8)
    .frame(maxHeight: ButtonHeight)
    .background(Theme.shared.colors.accentBackground)
    .foregroundStyle(Theme.shared.colors.accentText)
    .cornerRadius(6)
    .overlay {
      RoundedRectangle(cornerRadius: 8.0).fill(.clear).stroke(Theme.shared.colors.accent, style: .init(lineWidth: 1.0))
    }
    .scaleEffect(buttonScale)
    .animation(.spring(response: 0.3, dampingFraction: 0.4), value: buttonScale)
    .pressEvents {
      withAnimation { buttonScale = 0.9 }
    } onRelease: {
      withAnimation { buttonScale = 1.0 }
      action()
    }
  }
}

struct IconButton: View {
  let icon: Image
  let color: Color
  let action: () -> Void
  
  @State private var buttonScale: CGFloat = 1.0
  
  var body: some View {
    Button(action: action) {
      icon.renderingMode(.template).resizable().aspectRatio(contentMode: .fit).foregroundStyle(color)
    }
    .padding(8.0)
    .frame(maxHeight: ButtonHeight)
    .background(Theme.shared.colors.accentBackground)
    .overlay {
      RoundedRectangle(cornerRadius: 4.0).fill(.clear).stroke(Theme.shared.colors.accent, style: .init(lineWidth: 1.0))
    }
    .cornerRadius(4)
	  .scaleEffect(buttonScale)
    .animation(.spring(response: 0.2, dampingFraction: 0.6), value: buttonScale)
    .pressEvents {
      withAnimation { buttonScale = 0.8 }
    } onRelease: {
      withAnimation { buttonScale = 1.0 }
    }
  }
}

struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    @State private var buttonScale: CGFloat = 1.0

    var body: some View {
        HStack {
            Spacer()
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Theme.shared.colors.primaryButtonText)
            Spacer()
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(Theme.shared.colors.accent)
        .cornerRadius(12)
        .shadow(color: Theme.shared.colors.accent.opacity(0.3), radius: 8, y: 4)
        .scaleEffect(buttonScale)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: buttonScale)
        .pressEvents {
            withAnimation { buttonScale = 0.96 }
        } onRelease: {
            withAnimation {
                buttonScale = 1.0
                action()
            }
        }
    }
}

#Preview("Action Button") {
    VStack(spacing: 10) {
        ActionButton(
            icon: Image(systemName: "plus"),
            label: "Add Item",
            action: {}
        )
        
        ActionButton(
            icon: "star.fill",
            label: "Favorite",
            action: {}
        )
    }
    .padding()
  HStack{
    IconButton(
      icon: Image(systemName: "text.bubble"),
      color: Theme.shared.colors.red,
      action: {}
    )
    .frame(width: 40, height: 40)
    .padding()
    IconButton(
      icon: Image(systemName: "paragraph"),
      color: Theme.shared.colors.accentText,
      action: {}
    )
    
    .frame(width: 40, height: 40)
    .padding()
  }
    PrimaryButton(
        title: "Click Me",
        action: {}
    ).padding()
}

//#Preview("Everything") {
//  HStack {
//    ActionButton(icon: "plus", label: "Add Item", action: {})
//    IconButton(icon: Image(systemName: "text.bubble"), color: Theme.shared.colors.red, action: {})
//    PrimaryButton(title: "Click Me", action: {})
//    AdjusterView(icon: "textformat.size", value: .constant(CGFloat(16)), mode: .continuous(range: 8...32))
//  }
//}
