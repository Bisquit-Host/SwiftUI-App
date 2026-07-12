import ScrechKit

struct SpeedModeButtonView: View {
    @Binding var isEnabled: Bool
    let animationsEnabled: Bool

    var body: some View {
        Button(
            "Speed mode",
            systemImage: isEnabled ? "bolt.fill" : "bolt"
        ) {
            guard animationsEnabled else {
                isEnabled.toggle()
                return
            }

            withAnimation(.easeOut) {
                isEnabled.toggle()
            }
        }
        .labelStyle(.iconOnly)
        .title(design: .rounded)
        .foregroundStyle(isEnabled ? .yellow : .primary)
        .buttonStyle(.plain)
        .contentTransition(.symbolEffect(.replace))
        .accessibilityValue(isEnabled ? "Enabled" : "Disabled")
    }
}
