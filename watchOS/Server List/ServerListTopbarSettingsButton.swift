import ScrechKit

struct ServerListTopbarSettingsButton: View {
    var body: some View {
        NavigationLink {
            CalagopusSettings()
        } label: {
            Label("Settings", systemImage: "gear")
        }
    }
}

#Preview {
    ServerListTopbarSettingsButton()
        .darkSchemePreferred()
        .environment(NavState())
        .environmentObject(ValueStore())
}
