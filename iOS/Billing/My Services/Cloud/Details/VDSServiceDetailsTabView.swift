import SwiftUI

struct VDSServiceDetailsTabView: View {
    @State private var vm = VDSServiceDetailsVM()
    
    let serviceId: Int
    
    @State private var selectedTab = 0
    
    private var navTitle: LocalizedStringKey? {
        switch selectedTab {
        case 1: "Protection"
        case 2: "History"
        default: nil
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("General", systemImage: "gear", value: 0) {
                VDSServiceDetails(serviceId: serviceId)
            }
            
            Tab("Protection", systemImage: "shield.lefthalf.filled", value: 1) {
                VDSProtection(serviceId: serviceId)
            }
            
            Tab("History", systemImage: "clock", value: 2) {
                VDSServiceHistoryTab(serviceId: serviceId)
            }
        }
        .environment(vm)
        .navigationTitle(navTitle ?? "\(vm.service?.name ?? "")")
        .navigationBarTitleDisplayMode(.inline)
        .scrollIndicators(.never)
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
