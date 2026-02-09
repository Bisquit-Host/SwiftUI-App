import ScrechKit

struct ServerListToolbar: ViewModifier {
    @Environment(ServerListVM.self) private var vm
    @Environment(NavState.self) private var nav
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                // Admin server list
                ToolbarItem(placement: .topBarTrailing) {
                    ServerListAdminButton()
                }
                
                ToolbarSpacer(.fixed, placement: .topBarTrailing)
                
                // Discover
                ToolbarItem(placement: .topBarLeading) {
                    SFButton("sparkles") {
                        vm.sheetDiscover = true
                    }
                    .tint(Color.yellow.gradient)
                }
                
                // Settings
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Settings", systemImage: "gear") {
                        nav.navigate(.toSettings)
                    }
                    .keyboardShortcut("s")
                }
            }
    }
}

extension View {
    func serverListToolbar() -> some View {
        modifier(ServerListToolbar())
    }
}
