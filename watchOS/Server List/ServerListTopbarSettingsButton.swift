import ScrechKit

struct ServerListTopbarSettingsButton: View {
    @Environment(NavState.self) private var nav
    
    var body: some View {
        Button {
            nav.navigate(.toSettings)
        } label: {
            Image(systemName: "gear")
        }
    }
}

#Preview {
    ServerListTopbarSettingsButton()
        .darkSchemePreferred()
        .environment(NavState())
        .environmentObject(ValueStore())
}
