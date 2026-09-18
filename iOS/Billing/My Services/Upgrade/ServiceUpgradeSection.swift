import SwiftUI

struct ServiceUpgradeSection<VM: ServiceDetailsVMProtocol>: View {
    @Environment(VM.self) private var vm
    @Environment(DashboardVM.self) private var dashboardVM
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
            onUpgrade: handleUpgradeTap
        )
        .navigationTitle("Change plan")
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
            Button("Change plan", role: .confirm, action: upgrade)
            Button("Cancel", role: .cancel) {}
        } message: {
            if let pkg = selectedUpgradePackage {
                let priceNow = formatCurrency(pkg.amountDueNow, user: dashboardVM.user)
                
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
                        .environment(dashboardVM)
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


}

extension GameServiceDetailsVM: ServiceDetailsVM {
    var serviceId: Int? { service?.id }
}

extension BotServiceDetailsVM: ServiceDetailsVM {
    var serviceId: Int? { service?.id }
}
