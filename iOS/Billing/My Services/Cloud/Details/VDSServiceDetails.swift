import SwiftUI

struct VDSServiceDetails: View {
    @Environment(VDSServiceDetailsVM.self) private var vm
    @Environment(DashboardVM.self) private var dashboardVM
    
    private let serviceId: Int
    
    init(_ serviceId: Int) {
        self.serviceId = serviceId
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let service = vm.service {
                    VDSServiceDetailsHeader(service)
                    VDSServiceDetailsInfoSection(service)
                    VDSBillingSection(service)
                    VDSReinstallSection(service.id)
                    VDSMonitoringSection()
                    
                } else if vm.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 24)
                }
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
