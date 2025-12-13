import SwiftUI

struct VDSServiceDetails: View {
    @Environment(VDSServiceDetailsVM.self) private var vm
    @Environment(BillingDashboardVM.self) private var dashboardVM
    
    let serviceId: Int
    
    @State private var pendingName = ""
    @State private var rootPassword = ""
    @State private var selectedOS: Int?
    @State private var renewMonths = 1
    @State private var selectedUpgradeId: Int?
    @State private var alertRename = false
    @State private var alertUpgrade = false
    
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
                    
                    VDSUpgradeSection(selectedUpgradeId: $selectedUpgradeId, formatCurrency: formatCurrency) {
                        if selectedUpgradeId != nil {
                            alertUpgrade = true
                        }
                    }
                    
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
                selectedUpgradeId = vm.changeablePackages.first?.id
            }
            
            rootPassword = ""
        }
        .onChange(of: vm.changeablePackages.count) { _, _ in
            if selectedUpgradeId == nil {
                selectedUpgradeId = vm.changeablePackages.first?.id
            }
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
        .alert("Confirm upgrade", isPresented: $alertUpgrade) {
            Button("Upgrade", action: upgrade)
            Button("Cancel", role: .cancel) {}
        } message: {
            if let pkg = selectedUpgradePackage {
                Text("Upgrade to \(pkg.name) and pay \(formatCurrency(max(pkg.price - pkg.toMinus, 0))) now?")
            } else {
                Text("Upgrade service?")
            }
        }
    }
    
    private func upgrade() {
        guard let pkg = selectedUpgradePackage else { return }
        
        Task {
            await vm.changePackage(to: pkg.id, serviceId: serviceId)
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
    
    private var selectedUpgradePackage: ChangeableCloudPackage? {
        vm.changeablePackages.first {
            $0.id == selectedUpgradeId
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
