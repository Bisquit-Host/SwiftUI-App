import SwiftUI

struct VDSServiceDetails: View {
    @State private var vm = VDSServiceDetailsVM()
    @Environment(BillingDashboardVM.self) private var dashboardVM
    
    let serviceId: Int
    
    @State private var pendingName = ""
    @State private var rootPassword = ""
    @State private var selectedOS: Int?
    @State private var renewMonths = 1
    @State private var selectedUpgradeId: Int?
    @State private var alertRename = false
    @State private var alertUpgrade = false
    @State private var sheetCloudProtection = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let service = vm.service {
                    VDSServiceDetailsHeader(service)
                    
                    infoSection(service)
                    
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
                    
                    BillingSectionCard("Cloud Protection") {
                        Button("Manage protection") {
                            sheetCloudProtection = true
                        }
                        .frame(maxWidth: .infinity)
                        .buttonStyle(.borderedProminent)
                        .disabled(vm.isPerformingAction)
                    }
                    
                    passwordSection(service)
                    
                    VDSReinstallSection(serviceId: service.id, selectedOS: $selectedOS)
                    
                    VDSChartSection()
                    
                    VDSHistorySection()
                    
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
        .navigationTitle(vm.service?.name ?? "")
        .navigationBarTitleDisplayMode(.inline)
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
            Button("Upgrade") {
                guard let pkg = selectedUpgradePackage else { return }
                
                Task {
                    await vm.changePackage(to: pkg.id, serviceId: serviceId)
                }
            }
            
            Button("Cancel", role: .cancel) {}
        } message: {
            if let pkg = selectedUpgradePackage {
                Text("Upgrade to \(pkg.name) and pay \(formatCurrency(max(pkg.price - pkg.toMinus, 0))) now?")
            } else {
                Text("Upgrade service?")
            }
        }
        .sheet($sheetCloudProtection) {
            CloudProtectionSheet(serviceId: serviceId)
        }
        .environment(vm)
    }
    
    private func infoSection(_ service: BillingCloudServiceDetails) -> some View {
        BillingSectionCard("Details") {
            VStack(alignment: .leading, spacing: 10) {
                LabeledContent("Package", value: service.packageInfo.name)
                LabeledContent("CPU", value: "\(String(format: "%.1f", service.packageInfo.cpu)) vCPU \(service.packageInfo.cpuName ?? "")")
                LabeledContent("RAM", value: "\(String(format: "%.1f", service.packageInfo.memory)) GB")
                LabeledContent("Disk", value: "\(String(format: "%.0f", service.packageInfo.disk)) GB \(service.packageInfo.diskType ?? "")")
                LabeledContent("Location", value: service.location.name)
                
                if let expires = service.expiresAt {
                    LabeledContent("Expires", value: expires.formatted(date: .numeric, time: .shortened))
                }
            }
        }
    }
    
    private func passwordSection(_ service: BillingCloudServiceDetails) -> some View {
        BillingSectionCard("Root password") {
            VStack(alignment: .leading, spacing: 8) {
                SecureField("New password", text: $rootPassword)
                
                Button("Update password") {
                    Task {
                        await vm.changePassword(rootPassword, serviceId: service.id)
                    }
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
                .disabled(vm.isPerformingAction || rootPassword.count < 8)
            }
        }
    }
    
    // MARK: - Helpers
    
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
    
    private var selectedUpgradePackage: BillingChangeableCloudPackage? {
        vm.changeablePackages.first {
            $0.id == selectedUpgradeId
        }
    }
}

#Preview {
    NavigationStack {
        VDSServiceDetails(serviceId: 1)
            .environment(BillingDashboardVM())
    }
    .environmentObject(ValueStore())
    .darkSchemePreferred()
}
