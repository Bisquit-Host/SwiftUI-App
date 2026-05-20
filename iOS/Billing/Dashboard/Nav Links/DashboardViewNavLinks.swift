import SwiftUI
import ScrechKit

struct DashboardViewNavLinks: View {
    @Environment(DashboardViewVM.self) private var vm
    @Environment(NavState.self) private var nav
    
    var body: some View {
        VStack(spacing: 16) {
            BillingSectionCard("Manage", showsBackground: false) {
                VStack(spacing: 12) {
                    /*
                    DashboardViewNavLink("My services", subtitle: "VDS, game & bots", systemImage: "externaldrive.connected.to.line.below", tint: .blue) {
                        MyServicesList()
                            .environment(vm)
                    }
                    */
                    
                    Button {
                        nav.navigate(.toServerListParent)
                    } label: {
                        DashboardViewNavLinkLabel("Pterodactyl", subtitle: "Game Servers & Bots", systemImage: "externaldrive", tint: .purple)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            BillingSectionCard("Help", showsBackground: false) {
                VStack(spacing: 12) {
                    DashboardViewNavLink("Support", subtitle: "Tickets", systemImage: "lifepreserver", tint: .red) {
                        SupportView()
                    }
                    
                    DashboardViewNavLink("Wiki", subtitle: "How to...?", systemImage: "books.vertical", tint: .orange) {
                        SupportWikiView()
                    }
                }
            }
        }
    }
}
