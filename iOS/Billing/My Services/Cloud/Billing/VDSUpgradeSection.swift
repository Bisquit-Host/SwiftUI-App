import SwiftUI

struct VDSUpgradeSection: View {
    @Environment(VDSServiceDetailsVM.self) private var vm
    @Environment(BillingDashboardVM.self) private var dashboardVM
    @Environment(ConfettiVM.self) private var confetti
    
    let serviceId: Int
    
    @State private var alertUpgrade = false
    @State private var selectedUpgradeId: Int?
    
    private var selectedUpgradePackage: ChangeableCloudPackage? {
        vm.changeablePackages.first {
            $0.id == selectedUpgradeId
        }
    }
    
    var body: some View {
        VDSSectionCard("Upgrade") {
            if vm.changeablePackages.isEmpty {
                Text("No higher packages available right now")
                    .footnote()
                    .secondary()
            } else {
                ForEach(vm.changeablePackages) {
                    VDSUpgradePackage(pkg: $0, selectedUpgradeId: $selectedUpgradeId)
                }
                
                Button {
                    alertUpgrade = true
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
        guard let pkg = selectedUpgradePackage else { return }
        
        Task {
            await vm.changePackage(to: pkg.id, serviceId: serviceId) {
                confetti.launchConfetti()
            }
        }
    }
}
