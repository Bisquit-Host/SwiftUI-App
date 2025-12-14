import SwiftUI

struct VDSUpgradeSection: View {
    @Environment(VDSServiceDetailsVM.self) private var vm
    @Environment(BillingDashboardVM.self) private var dashboardVM
    
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
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(vm.changeablePackages) {
                        VDSUpgradePackage(pkg: $0, selectedUpgradeId: $selectedUpgradeId, formatCurrency: formatCurrency)
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
}
