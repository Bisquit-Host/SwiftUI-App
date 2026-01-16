import SwiftUI
import ScrechKit

struct DashboardViewNavLinks: View {
    @Environment(DashboardViewVM.self) private var vm
    @Environment(NavState.self) private var nav
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        VStack(spacing: 16) {
            DashboardViewNavLink("My services", subtitle: "VDS, game & bots", systemImage: "externaldrive.connected.to.line.below", tint: .blue) {
                MyServicesList()
                    .environment(vm)
            }
            
            DashboardViewNavLink("Support", subtitle: "Tickets & wiki", systemImage: "lifepreserver", tint: .red) {
                SupportView()
            }
            
            Button {
                nav.navigate(.toServerListParent)
            } label: {
                DashboardViewNavLinkLabel("Pterodactyl", subtitle: "Servers", systemImage: "externaldrive", tint: .purple)
            }
        }
    }
}
