import SwiftUI

struct VDSUpgradeSection: View {
    @Environment(VDSServiceDetailsVM.self) private var vm
    
    @Binding var selectedUpgradeId: Int?
    let formatCurrency: (Double) -> String
    let onUpgradeTap: () -> Void
    
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
                                    
                                    Text("\(pkg.cpu.clean) vCPU • \(pkg.memory.clean) GB • \(Int(pkg.disk)) GB")
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
                    
                    Button(action: onUpgradeTap) {
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
    }
}
