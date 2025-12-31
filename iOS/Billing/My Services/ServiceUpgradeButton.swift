import SwiftUI

struct ServiceUpgradeButton<VM: ServiceDetailsVMProtocol>: View {
    @Environment(VM.self) private var vm
    
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
#if !os(visionOS)
        .buttonStyle(.glassProminent)
#endif
        .disabled(vm.isPerformingAction)
        .padding(.horizontal, 8)
        .sheet($sheetUpgrade) {
            NavigationStack {
                ServiceUpgradeSection<VM>()
            }
        }
    }
}

//#Preview {
//    ServiceUpgradeButton()
//}
