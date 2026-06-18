import SwiftUI

struct VDSUpgradeSection: View {
    @Environment(VDSServiceDetailsVM.self) private var vm
    @Environment(DashboardVM.self) private var dashboardVM
    @Environment(ConfettiVM.self) private var confetti
    @Environment(BiometryVM.self) private var biometry
    @EnvironmentObject private var store: ValueStore
    
    private let serviceId: Int
    
    init(_ serviceId: Int) {
        self.serviceId = serviceId
    }
    
    @State private var alertUpgrade = false
    @State private var selectedUpgradeId: Int?
    @State private var sheetTopup = false
    @State private var showTopupAlert = false
    
    private var selectedUpgradePackage: ChangeablePackage? {
        vm.changeablePackages.first {
            $0.id == selectedUpgradeId
        }
    }
    
    var body: some View {
        @Bindable var vm = vm
        
        UpgradeFullScreenView(
            packages: vm.changeablePackages,
            selectedUpgradeId: $selectedUpgradeId,
            isPerformingAction: vm.isPerformingAction,
            buttonTitle: upgradeButtonTitle,
            buttonSubtitle: upgradeButtonSubtitle,
            onUpgrade: handleUpgradeTap
        ) {
            UpgradeNoticeView("VDS services can't be downgraded for technical reasons")
        } summary: {
            if let pkg = selectedUpgradePackage {
                UpgradeSelectionSummary(name: pkg.name, priceNow: selectedPriceNow, monthlyPrice: selectedMonthlyPrice)
            }
        }
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
        .alert("Confirm plan change", isPresented: $alertUpgrade) {
            Button("Change plan", role: .confirmy, action: upgrade)
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
            guard let pkg = selectedUpgradePackage else { return }
            
            if store.useBiometry, await !biometry.authenticate() {
                SystemAlert.error("Biometry authentication failed")
                return
            }
            
            await vm.changePackage(to: pkg.id, serviceId: serviceId, onSuccess: confetti.launchConfetti)
        }
    }
    
    private var selectedPriceNow: String {
        guard let pkg = selectedUpgradePackage else { return "" }
        
        return formatCurrency(pkg.amountDueNow, user: dashboardVM.user)
    }
    
    private var selectedMonthlyPrice: String {
        guard let pkg = selectedUpgradePackage else { return "" }
        
        return formatCurrency(pkg.price, user: dashboardVM.user)
    }
    
    private var upgradeButtonTitle: String {
        guard let pkg = selectedUpgradePackage else { return "Change plan" }
        
        return "Change plan to \(pkg.name)"
    }
    
    private var upgradeButtonSubtitle: String? {
        guard selectedUpgradePackage != nil else { return nil }
        
        return "Pay \(selectedPriceNow) now"
    }
}
