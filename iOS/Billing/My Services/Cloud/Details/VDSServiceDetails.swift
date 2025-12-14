import SwiftUI

struct VDSServiceDetails: View {
    @Environment(VDSServiceDetailsVM.self) private var vm
    @Environment(BillingDashboardVM.self) private var dashboardVM
    
    let serviceId: Int
    
    @State private var pendingName = ""
    @State private var rootPassword = ""
    @State private var selectedOS: Int?
    @State private var renewMonths = 1
    @State private var alertRename = false
    
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
                        expiresAt: vm.service?.expiresAt ?? service.expiresAt,
                        formatCurrency: formatCurrency
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if vm.isPerformingAction {
                    ProgressView()
                } else {
                    Menu {
                        Button("Rename", systemImage: "pencil") {
                            alertRename = true
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
            }
        }
        .onChange(of: vm.service?.id) { _, _ in
            if let service = vm.service {
                pendingName = service.name
                renewMonths = 1
            }
            
            rootPassword = ""
        }
        .alert("Rename service", isPresented: $alertRename, presenting: vm.service) { service in
            TextField("New name", text: $pendingName)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            
            Button("Save") {
                Task {
                    await vm.rename(pendingName.isEmpty ? service.name : pendingName, serviceId: service.id)
                }
            }
            
            Button("Cancel", role: .cancel) {}
        }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        
        let value = formatter.string(from: NSNumber(value: amount)) ?? amount.formatted(.fractionDigits(2))
        
        if let user = dashboardVM.user {
            return user.currency.symbol + value
        } else {
            return value
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
