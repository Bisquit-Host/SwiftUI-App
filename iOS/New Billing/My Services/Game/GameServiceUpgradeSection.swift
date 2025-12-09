import SwiftUI

struct GameServiceUpgradeSection: View {
    @Environment(GameServiceDetailsVM.self) private var vm
    @Environment(BillingDashboardVM.self) private var dashboardVM
    
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
                    ForEach(vm.changeablePackages) { pkg in
                        Button {
                            selectedUpgradeId = pkg.id
                        } label: {
                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(pkg.name)
                                        .subheadline(.semibold)
                                    
                                    Text("\(pkg.cpu.clean) vCPU • \(pkg.memory.clean) GB • \(pkg.disk.clean) GB")
                                        .footnote()
                                        .secondary()
                                    
                                    Text("Pay now \(formatCurrency(max(pkg.price - pkg.toMinus, 0))) / \(formatCurrency(pkg.price))/mo")
                                        .footnote()
                                        .foregroundStyle(.primary)
                                }
                                
                                Spacer()
                                
                                if selectedUpgradeId == pkg.id {
                                    Image(systemName: "checkmark.circle.fill")
                                }
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedUpgradeId == pkg.id ? Color.accentColor.opacity(0.12) : Color.clear)
                            }
                        }
                        .buttonStyle(.plain)
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
            Button("Upgrade") {
                guard let pkg = selectedUpgradePackage, let serviceId = vm.service?.id else { return }
                
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
    }
    
    private var selectedUpgradePackage: BillingChangeableGamePackage? {
        vm.changeablePackages.first { $0.id == selectedUpgradeId }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        
        let value = formatter.string(from: NSNumber(value: amount)) ?? String(format: "%.2f", amount)
        
        if let user = dashboardVM.user {
            return user.currency.symbol + " " + value
        } else {
            return value
        }
    }
}
