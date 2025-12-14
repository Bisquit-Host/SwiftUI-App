import SwiftUI

struct VDSServiceDetailsTabView: View {
    @State private var vm = VDSServiceDetailsVM()
    
    let serviceId: Int
    
    @State private var selectedTab = 0
    
    private var title: LocalizedStringKey? {
        switch selectedTab {
        case 1: "Protection"
        case 2: "History"
        default: nil
        }
    }
    
    private var subtitle: String {
        guard
            selectedTab == 0,
            let name = vm.service?.packageInfo.name,
            let location = vm.service?.location.name
        else {
            return ""
        }
        
        return "\(name) • \(location)"
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
        .navigationTitle(title ?? "\(vm.service?.name ?? "")")
        .navigationSubtitle(subtitle)
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
