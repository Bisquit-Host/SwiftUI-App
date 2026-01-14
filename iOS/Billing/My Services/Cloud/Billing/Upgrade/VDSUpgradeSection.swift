import SwiftUI

struct VDSUpgradeSection: View {
    @Environment(VDSServiceDetailsVM.self) private var vm
    @Environment(BillingDashboardVM.self) private var dashboardVM
    @Environment(ConfettiVM.self) private var confetti
    @Environment(BiometryVM.self) private var biometry
    @EnvironmentObject private var store: ValueStore
    
    private let serviceId: Int
    
    init(_ serviceId: Int) {
        self.serviceId = serviceId
    }
    
    @State private var alertUpgrade = false
    @State private var selectedUpgradeId: Int?
    
    private var selectedUpgradePackage: ChangeablePackage? {
        vm.changeablePackages.first {
            $0.id == selectedUpgradeId
        }
    }
    
    var body: some View {
        ServiceSectionCard("Upgrade") {
            vdsUpgradeNotice
            
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
    
    private var vdsUpgradeNotice: some View {
        HStack(spacing: 8) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(.orange)
            
            Text("VDS services can't be downgraded for technical reasons")
                .footnote()
                .secondary()
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.orange.opacity(0.1), in: .rect(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(.orange.opacity(0.25), lineWidth: 1)
        }
    }
}
