import SwiftUI
import ScrechKit

struct BillingDashboardNavLinks: View {
    @Environment(DashboardViewVM.self) private var vm
    @Environment(NavState.self) private var nav
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        VStack(spacing: 16) {
            BillingDashboardNavLink("My services", subtitle: "VDS, game & bots", systemImage: "externaldrive.connected.to.line.below", tint: .blue) {
                MyServicesList()
                    .environment(vm)
            }
            
            BillingDashboardNavLink("Support", subtitle: "Tickets & wiki", systemImage: "lifepreserver", tint: .red) {
                SupportView()
            }
            
            Button {
                nav.navigate(.toServerListParent)
            } label: {
                BillingDashboardNavLinkLabel("Pterodactyl", subtitle: "Servers", systemImage: "externaldrive", tint: .purple)
            }
        }
    }
}
