import ScrechKit

struct ServerListTopbarSettingsButton: View {
    @Environment(ServerListVM.self) private var vm
    @Environment(NavState.self) private var nav
    @EnvironmentObject private var store: ValueStore
    
    @State private var isRotating = false
    
    var body: some View {
        Button {
            nav.navigate(.toSettings)
        } label: {
            Image(systemName: "gear")
                .secondary()
                .rotate(isRotating ? 360 : 0)
                .animation(
                    .linear(duration: 60).repeatForever(autoreverses: false),
                    value: isRotating
                )
        }
        .task {
            isRotating = true
        }
    }
}

#Preview {
    ServerListTopbarSettingsButton()
        .darkSchemePreferred()
        .environment(ServerListVM())
        .environment(NavState())
        .environmentObject(ValueStore())
}
