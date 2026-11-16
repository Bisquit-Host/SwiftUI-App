import ScrechKit

struct ServerListToolbar: ViewModifier {
    let showsSettings: Bool
    
    @Environment(ServerListVM.self) private var vm
    @Environment(NavState.self) private var nav
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                // Admin server list
                ToolbarItem(placement: .topBarLeading) {
                    ServerListAdminButton()
                }
                
                // Discover
                ToolbarItem(placement: .topBarTrailing) {
                    SFButton("sparkles") {
                        vm.sheetDiscover = true
                    }
                    .tint(Color.yellow.gradient)
                }
                
                if showsSettings {
                    ToolbarSpacer(.fixed, placement: .topBarTrailing)
                    
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
}

extension View {
    func serverListToolbar(showsSettings: Bool = true) -> some View {
        modifier(ServerListToolbar(showsSettings: showsSettings))
    }
}
