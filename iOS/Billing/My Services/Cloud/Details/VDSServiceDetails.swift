import SwiftUI

struct VDSServiceDetails: View {
    @Environment(VDSServiceDetailsVM.self) private var vm
    @Environment(BillingDashboardVM.self) private var dashboardVM
    
    let serviceId: Int
    
    @State private var rootPassword = ""
    @State private var selectedOS: Int?
    @State private var renewMonths = 1
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let service = vm.service {
                    VDSServiceDetailsHeader(service)
                    VDSServiceDetailsInfoSection(service)
                    
                    VDSBillingSection(
                        serviceId: service.id,
                        autorenew: vm.service?.autorenew ?? service.autorenew,
                        renewMonths: $renewMonths,
                        expiresAt: vm.service?.expiresAt ?? service.expiresAt
                    )
                    
                    VDSPowerSection(serviceId: service.id)
                    
                    VDSServiceDetailsPasswordSection(service, rootPassword: $rootPassword)
                    
                    VDSReinstallSection(serviceId: service.id, selectedOS: $selectedOS)
                    
                    VDSMonitoringSection()
                    
                } else if vm.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 24)
                }
                
                if let message = vm.actionMessage {
                    Text(message)
                        .footnote()
                        .foregroundStyle(.green)
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
        VDSServiceDetails(serviceId: 1)
            .environment(BillingDashboardVM())
            .environment(VDSServiceDetailsVM())
    }
    .environmentObject(ValueStore())
    .darkSchemePreferred()
}
