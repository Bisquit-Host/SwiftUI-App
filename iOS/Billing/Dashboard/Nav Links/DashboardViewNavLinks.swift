import ScrechKit

struct DashboardNavLinks: View {
    @Environment(DashboardVM.self) private var vm
    @Environment(NavState.self) private var nav
    
    var body: some View {
        VStack(spacing: 16) {
            BillingSectionCard("Manage", showsBackground: false) {
                VStack(spacing: 12) {
                    /*
                    DashboardNavLink("My services", subtitle: "VDS, game & bots", systemImage: "externaldrive.connected.to.line.below", tint: .blue) {
                        MyServicesList()
                            .environment(vm)
                    }
                    */
                    
                    Button {
                        nav.navigate(.toServerListParent)
                    } label: {
                        DashboardNavLinkLabel("Pterodactyl", subtitle: "Game Servers & Bots", systemImage: "externaldrive", tint: .purple)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            BillingSectionCard("Help", showsBackground: false) {
                VStack(spacing: 12) {
                    DashboardNavLink("Support", subtitle: "Tickets", systemImage: "lifepreserver", tint: .red) {
                        SupportView()
                    }
                    
                    DashboardNavLink("Wiki", subtitle: "How to...?", systemImage: "books.vertical", tint: .orange) {
                        SupportWikiView()
                    }
                }
            }
        }
    }
}
