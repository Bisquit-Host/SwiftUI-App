import ScrechKit

struct ServerListToolbar: ViewModifier {
    @Environment(ServerListVM.self) private var vm
    @Environment(NavState.self) private var nav
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                // Discover
                ToolbarItem(placement: .topBarLeading) {
                    SFButton("sparkles") {
                        vm.sheetDiscover = true
                    }
                    .tint(Color.yellow.gradient)
                }
                
                // Admin server list
                ToolbarItem(placement: .topBarTrailing) {
                    ServerListAdminButton()
                }
                
                // Filter
                if vm.showFilter {
                    ToolbarItem(placement: .topBarTrailing) {
                        ServerListFilter()
                    }
                }
                
                ToolbarSpacer(.fixed, placement: .topBarTrailing)
                
                // Settings
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Settings", systemImage: "gear") {
                        nav.navigate(.toSettings)
                    }
                }
            }
    }
}

extension View {
    func serverListToolbar() -> some View {
        modifier(ServerListToolbar())
    }
}
