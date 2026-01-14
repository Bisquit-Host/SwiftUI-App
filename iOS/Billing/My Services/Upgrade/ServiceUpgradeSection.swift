import SwiftUI

struct ServiceUpgradeSection<VM: ServiceDetailsVMProtocol>: View {
    @Environment(VM.self) private var vm
    @Environment(BillingDashboardVM.self) private var dashboardVM
    @Environment(ConfettiVM.self) private var confetti
    @Environment(BiometryVM.self) private var biometry
    @EnvironmentObject private var store: ValueStore
    
    @State private var selectedUpgradeId: Int?
    @State private var alertUpgrade = false
    
    var body: some View {
        ServiceSectionCard("Upgrade") {
            if vm.changeablePackages.isEmpty {
                Text("No higher packages available right now")
                    .footnote()
                    .secondary()
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(vm.changeablePackages) {
                        UpgradePackage(pkg: $0, selectedUpgradeId: $selectedUpgradeId)
                    }
                    
                    if let pkg = selectedUpgradePackage {
                        UpgradeSelectionSummary(name: pkg.name, priceNow: selectedPriceNow, monthlyPrice: selectedMonthlyPrice)
                    }
                    
                    Button {
                        if selectedUpgradeId != nil {
                            alertUpgrade = true
                        }
                    } label: {
                        if vm.isPerformingAction {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            VStack(spacing: 2) {
                                Text(upgradeButtonTitle)
                                    .semibold()
                                
                                if let subtitle = upgradeButtonSubtitle {
                                    Text(subtitle)
                                        .footnote()
                                        .secondary()
                                        .monospacedDigit()
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(selectedUpgradeId == nil || vm.isPerformingAction)
                }
            }
        }
        .onAppear {
            if selectedUpgradePackage == nil {
                selectedUpgradeId = vm.changeablePackages.first?.id
            }
        }
        .onChange(of: vm.changeablePackages.count) {
            if selectedUpgradePackage == nil {
                selectedUpgradeId = vm.changeablePackages.first?.id
            }
        }
        .alert("Confirm upgrade", isPresented: $alertUpgrade) {
            Button("Upgrade", role: .confirm, action: upgrade)
            Button("Cancel", role: .cancel) {}
        } message: {
            if let pkg = selectedUpgradePackage {
                let priceNow = formatCurrency(max(pkg.price - pkg.toMinus, 0), user: dashboardVM.user)
                
                Text("Upgrade to \(pkg.name) and pay \(priceNow) now?")
            } else {
                Text("Upgrade service?")
            }
        }
    }
    
    private func upgrade() {
        Task {
            guard let pkg = selectedUpgradePackage, let serviceId = vm.serviceId else { return }
            
            if store.useBiometry, await !biometry.authenticate() {
                SystemAlert.error("Biometry authentication failed")
                return
            }
            
            await vm.changePackage(to: pkg.id, serviceId: serviceId, onSuccess: confetti.launchConfetti)
        }
    }
    
    private var selectedUpgradePackage: ChangeablePackage? {
        vm.changeablePackages.first {
            $0.id == selectedUpgradeId
        }
    }
    
    private var selectedPriceNow: String {
        guard let pkg = selectedUpgradePackage else { return "" }
        
        return formatCurrency(max(pkg.price - pkg.toMinus, 0), user: dashboardVM.user)
    }
    
    private var selectedMonthlyPrice: String {
        guard let pkg = selectedUpgradePackage else { return "" }
        
        return formatCurrency(pkg.price, user: dashboardVM.user)
    }
    
    private var upgradeButtonTitle: String {
        guard let pkg = selectedUpgradePackage else { return "Upgrade" }
        
        return "Upgrade to \(pkg.name)"
    }
    
    private var upgradeButtonSubtitle: String? {
        guard selectedUpgradePackage != nil else { return nil }
        
        return "Pay \(selectedPriceNow) now"
    }
}

extension GameServiceDetailsVM: ServiceDetailsVM {
    var serviceId: Int? { service?.id }
}

extension BotServiceDetailsVM: ServiceDetailsVM {
    var serviceId: Int? { service?.id }
}
