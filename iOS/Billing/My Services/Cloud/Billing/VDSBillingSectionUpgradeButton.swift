import SwiftUI

struct VDSBillingSectionUpgradeButton: View {
    @Environment(VDSServiceDetailsVM.self) private var vm
    
    private let serviceId: Int
    
    init(_ serviceId: Int) {
        self.serviceId = serviceId
    }
    
    @State private var sheetUpgrade = false
    
    var body: some View {
        Button {
            sheetUpgrade = true
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
        .buttonStyle(.glassProminent)
        .disabled(vm.isPerformingAction)
        .padding(.horizontal, 8)
        .sheet($sheetUpgrade) {
            NavigationStack {
                VDSUpgradeSection(serviceId)
            }
        }
    }
}

//#Preview {
//    VDSBillingSectionUpgradeButton()
//        .darkSchemePreferred()
//}
