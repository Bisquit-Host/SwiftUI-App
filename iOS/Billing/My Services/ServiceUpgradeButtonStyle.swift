import SwiftUI

#if !os(visionOS)
struct ServiceUpgradeButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    let isUnavailable: Bool
    let animation: Animation?

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 7)
            .foregroundStyle(.white)
            .background {
                Capsule()
                    .fill(Color.accentColor)
                    .glassEffect(.regular.interactive(), in: .capsule)
                    .saturation(isUnavailable ? 0 : 1)
                    .opacity(isEnabled ? 1 : 0.5)
            }
            .opacity(configuration.isPressed ? 0.8 : 1)
            .animation(animation, value: isUnavailable)
            .animation(animation, value: isEnabled)
            .animation(animation, value: configuration.isPressed)
    }
}
#endif
