import SwiftUI

struct CarouselButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial.shadow(.inner(
                    radius: configuration.isPressed ? 3 : 0)))
                .frame(width: 44, height: 44)
            
            configuration.label
                .labelStyle(.iconOnly)
                .foregroundStyle(isEnabled ? .black : .secondary)
                .opacity(configuration.isPressed ? 0.3 : 0.8)
        }
    }
}
