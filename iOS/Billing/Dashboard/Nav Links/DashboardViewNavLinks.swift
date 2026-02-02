import SwiftUI
import ScrechKit

struct DashboardViewNavLinks: View {
    @Environment(DashboardViewVM.self) private var vm
    @Environment(NavState.self) private var nav
    
    var body: some View {
        VStack(spacing: 16) {
            BillingSectionCard("Manage") {
                VStack(spacing: 12) {
                    DashboardViewNavLink("My services", subtitle: "VDS, game & bots", systemImage: "externaldrive.connected.to.line.below", tint: .blue) {
                        MyServicesList()
                            .environment(vm)
                    }
                    Button {
                        nav.navigate(.toServerListParent)
                    } label: {
                        DashboardViewNavLinkLabel("Pterodactyl", subtitle: "Servers", systemImage: "externaldrive", tint: .purple)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            BillingSectionCard("Help") {
                DashboardViewNavLink("Support", subtitle: "Tickets & wiki", systemImage: "lifepreserver", tint: .red) {
                    SupportView()
                }
            }
        }
    }
}
