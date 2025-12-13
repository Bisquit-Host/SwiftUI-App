import SwiftUI

struct VDSUpgradeSection: View {
    @Environment(VDSServiceDetailsVM.self) private var vm
    
    @Binding var selectedUpgradeId: Int?
    let formatCurrency: (Double) -> String
    let onUpgradeTap: () -> Void
    
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
