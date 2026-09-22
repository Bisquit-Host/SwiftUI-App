import SwiftUI

struct VDSServiceDetails: View {
    @Environment(VDSServiceDetailsVM.self) private var vm
    
    private let serviceId: Int
    
    init(_ serviceId: Int) {
        self.serviceId = serviceId
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VDSServiceDetailsHeader(vm.service)
                VDSServiceDetailsInfoSection(vm.service)
                VDSBillingSection(vm.service)
                    .id(serviceId)
                
                VDSMonitoringSection()
            }
            .padding()
        }
        .refreshableTask {
            await vm.load(serviceId)
        }
    }
}

#Preview {
    NavigationStack {
        VDSServiceDetails(1)
            .environment(DashboardVM())
            .environment(VDSServiceDetailsVM())
    }
    .environmentObject(ValueStore())
    .darkSchemePreferred()
}
