import SwiftUI
import ScrechKit

struct BillingDashboardNavLinks: View {
    @Environment(BillingDashboardVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        VStack(spacing: 16) {
            BillingDashboardNavLink("My services", subtitle: "VDS, game & bots", systemImage: "externaldrive.connected.to.line.below", tint: .blue) {
                BillingMyServicesList()
                    .environment(vm)
            }
            
            BillingDashboardNavLink("Support", subtitle: "Tickets & wiki", systemImage: "lifepreserver", tint: .red) {
                SupportView()
            }
            
            BillingDashboardNavLink("Pterodactyl", subtitle: "Servers", systemImage: "externaldrive", tint: .purple) {
                if store.isApiKeyValid {
                    ServerList()
                } else {
                    StartPage()
                }
            }
        }
    }
}
