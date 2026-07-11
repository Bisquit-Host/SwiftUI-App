import ScrechKit

struct SpeedModeIconView: View {
    let isEnabled: Bool
    let textStyle: Font

    var body: some View {
        Image(systemName: isEnabled ? "bolt.fill" : "bolt")
            .font(textStyle)
            .rounded()
            .foregroundStyle(isEnabled ? .yellow : .primary)
            .contentTransition(.symbolEffect(.replace))
            .accessibilityLabel("Speed mode")
            .accessibilityValue(isEnabled ? "Enabled" : "Disabled")
    }
}
