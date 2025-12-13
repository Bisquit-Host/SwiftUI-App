import SwiftUI

struct VDSServiceDetailsTabView: View {
    @State private var vm = VDSServiceDetailsVM()
    
    let serviceId: Int
    
    var body: some View {
        TabView {
            Tab("General", systemImage: "gear") {
                VDSServiceDetails(serviceId: serviceId)
            }
            
            Tab("Protection", systemImage: "shield.pattern.checkered") {
                CloudProtection(serviceId: serviceId)
            }
            
            Tab("History", systemImage: "clock") {
                VDSServiceHistoryTab(serviceId: serviceId)
            }
        }
        .environment(vm)
    }
}

#Preview {
    NavigationStack {
        VDSServiceDetailsTabView(serviceId: 1)
            .environment(BillingDashboardVM())
    }
    .environmentObject(ValueStore())
    .darkSchemePreferred()
}
