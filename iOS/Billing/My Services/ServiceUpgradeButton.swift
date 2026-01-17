import SwiftUI

struct ServiceUpgradeButton<VM: ServiceDetailsVMProtocol>: View {
    @Environment(VM.self) private var vm
    
    @State private var sheetUpgrade = false
    
    var body: some View {
        let showNoUpgrades = vm.service != nil && vm.changeablePackages.isEmpty
        
        Button {
            sheetUpgrade = true
        } label: {
            if vm.isPerformingAction {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else {
                VStack(spacing: 2) {
                    Text("Upgrade")
                        .semibold()
                    
                    if showNoUpgrades {
                        Text("No higher packages available right now")
                            .caption2()
                            .secondary()
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
#if !os(visionOS)
        .buttonStyle(.glassProminent)
#endif
        .tint(showNoUpgrades ? .gray : .accentColor)
        .disabled(vm.isPerformingAction || showNoUpgrades)
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
