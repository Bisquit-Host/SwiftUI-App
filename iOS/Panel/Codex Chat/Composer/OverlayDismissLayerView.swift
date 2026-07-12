import ScrechKit

struct OverlayDismissLayerView: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Color.black
                .opacity(0.001)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .ignoresSafeArea()
        .accessibilityLabel("Close model picker")
    }
}
