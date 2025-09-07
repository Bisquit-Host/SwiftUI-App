import ScrechKit

struct ServerListToolbar: ViewModifier {
    @Environment(ServerListVM.self) private var vm
    @Environment(NavState.self) private var nav
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    SFButton("sparkles") {
                        vm.sheetDiscover = true
                    }
                    .tint(Color.yellow.gradient)
                }
                
                ToolbarItemGroup(placement: .topBarTrailing) {
                    ServerListAdminButton()
                    
                    ServerListFilter()
                }
                
                ToolbarSpacer(.fixed, placement: .topBarTrailing)
                
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
