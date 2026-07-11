import ScrechKit

struct SpeedModeIconView: View {
    let isEnabled: Bool
    let textStyle: Font
    var coordinateSpaceName: String? = nil
    var frameChanged: ((CGRect) -> Void)? = nil

    var body: some View {
        Image(systemName: isEnabled ? "bolt.fill" : "bolt")
            .font(textStyle)
            .rounded()
            .foregroundStyle(isEnabled ? .yellow : .primary)
            .contentTransition(.symbolEffect(.replace))
            .accessibilityLabel("Speed mode")
            .accessibilityValue(isEnabled ? "Enabled" : "Disabled")
            .onGeometryChange(for: CGRect.self) {
                guard let coordinateSpaceName else { return .zero }

                return $0.frame(in: .named(coordinateSpaceName))
            } action: {
                frameChanged?($0)
            }
    }
}
