import ScrechKit

struct NetworkLostView: View {
    var body: some View {
        ContentUnavailableView {
            Label("No Internet Connection", systemImage: "network.slash")
        } description: {
            Text("Your iPhone is not connected to the internet. To connect, turn off Airplane Mode or connect to a Wi-Fi network.")
        } actions: {
#if !os(macOS) && !os(watchOS)
            Button("Go to settings") {
                openSettings()
            }
#endif
        }
    }
}

#Preview {
    NetworkLostView()
        .darkSchemePreferred()
#if os(visionOS)
        .glassBackgroundEffect()
#endif
}
