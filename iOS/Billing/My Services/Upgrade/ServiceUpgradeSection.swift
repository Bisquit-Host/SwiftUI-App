import SwiftUI

struct ServiceUpgradeSection<VM: ServiceDetailsVMProtocol>: View {
    @Environment(VM.self) private var vm
    @Environment(DashboardViewVM.self) private var dashboardVM
    @Environment(ConfettiVM.self) private var confetti
    @Environment(BiometryVM.self) private var biometry
    @EnvironmentObject private var store: ValueStore
    
    @State private var selectedUpgradeId: Int?
    @State private var alertUpgrade = false
    @State private var sheetTopup = false
    @State private var showTopupAlert = false
    
    var body: some View {
        @Bindable var vm = vm
        
        UpgradeFullScreenView(
            packages: vm.changeablePackages,
            selectedUpgradeId: $selectedUpgradeId,
            isPerformingAction: vm.isPerformingAction,
            buttonTitle: upgradeButtonTitle,
            buttonSubtitle: upgradeButtonSubtitle,
            onUpgrade: handleUpgradeTap,
            summary: {
                if let pkg = selectedUpgradePackage {
                    UpgradeSelectionSummary(name: pkg.name, priceNow: selectedPriceNow, monthlyPrice: selectedMonthlyPrice)
                }
            }
        )
        .navigationTitle("Upgrade")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if selectedUpgradePackage == nil {
                selectedUpgradeId = vm.changeablePackages.first?.id
            }
            showTopupAlert = vm.topupAlertContext == .upgrade
        }
        .onChange(of: vm.changeablePackages.count) {
            if selectedUpgradePackage == nil {
                selectedUpgradeId = vm.changeablePackages.first?.id
            }
        }
        .onChange(of: vm.topupAlertContext) { _, newValue in
            showTopupAlert = newValue == .upgrade
        }
        .onChange(of: showTopupAlert) { _, newValue in
            if !newValue, vm.topupAlertContext == .upgrade {
                vm.topupAlertContext = nil
            }
        }
        .alert("Confirm upgrade", isPresented: $alertUpgrade) {
            Button("Upgrade", role: .confirmy, action: upgrade)
            Button("Cancel", role: .cancel) {}
        } message: {
            if let pkg = selectedUpgradePackage {
                let priceNow = formatCurrency(max(pkg.price - pkg.toMinus, 0), user: dashboardVM.user)
                
                Text("Upgrade to \(pkg.name) and pay \(priceNow) now?")
            } else {
                Text("Upgrade service?")
            }
        }
        .alert("Insufficient funds", isPresented: $showTopupAlert) {
            Button("Dismiss", role: .cancel) {}
            Button("Top up") {
                vm.topupAlertContext = nil
                sheetTopup = true
            }
        } message: {
            Text("Add funds to continue")
        }
        .sheet($sheetTopup) {
            NavigationStack {
                if let user = dashboardVM.user {
                    SheetTopup(user)
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
    }
    
    private func handleUpgradeTap() {
        if selectedUpgradeId != nil {
            alertUpgrade = true
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
