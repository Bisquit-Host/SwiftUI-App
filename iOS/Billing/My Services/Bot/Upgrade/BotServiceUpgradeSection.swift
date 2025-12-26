import SwiftUI

struct BotServiceUpgradeSection: View {
    @Environment(BotServiceDetailsVM.self) private var vm
    @Environment(BillingDashboardVM.self) private var dashboardVM
    @Environment(ConfettiVM.self) private var confetti
    
    @State private var selectedUpgradeId: Int?
    @State private var alertUpgrade = false
    
    var body: some View {
        BillingSectionCard("Upgrade") {
            if vm.changeablePackages.isEmpty {
                Text("No higher packages available right now")
                    .footnote()
                    .secondary()
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(vm.changeablePackages) {
                        BotUpgradePackage(pkg: $0, selectedUpgradeId: $selectedUpgradeId)
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
                            Text("Upgrade")
                                .semibold()
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(selectedUpgradeId == nil || vm.isPerformingAction)
                }
            }
        }
        .onAppear { selectedUpgradeId = selectedUpgradeId ?? vm.changeablePackages.first?.id }
        .onChange(of: vm.changeablePackages.count) { _, _ in
            if selectedUpgradeId == nil {
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
        guard let pkg = selectedUpgradePackage, let serviceId = vm.service?.id else { return }
        
        Task {
            await vm.changePackage(to: pkg.id, serviceId: serviceId) {
                confetti.launchConfetti()
            }
        }
    }
    
    private var selectedUpgradePackage: ChangeableBotPackage? {
        vm.changeablePackages.first {
            $0.id == selectedUpgradeId
        }
    }
}
