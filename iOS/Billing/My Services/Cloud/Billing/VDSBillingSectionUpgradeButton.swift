import SwiftUI

struct VDSBillingSectionUpgradeButton: View {
    @Environment(VDSServiceDetailsVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    private let serviceId: Int
    
    init(_ serviceId: Int) {
        self.serviceId = serviceId
    }
    
    @State private var sheetUpgrade = false
    
    var body: some View {
        let isBusy = vm.service == nil || vm.isLoading || vm.isPerformingAction
        let animation: Animation? = store.bigAssAnimations && !reduceMotion ? .smooth : nil
        let showNoUpgrades = !vm.isLoading && vm.service != nil && vm.changeablePackages.isEmpty
        
        Button {
            sheetUpgrade = true
        } label: {
            if isBusy {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .transition(.opacity)
            } else {
                VStack(spacing: 2) {
                    Text("Change plan")
                        .semibold()
                    
                    if showNoUpgrades {
                        Text("No higher packages available right now")
                            .caption2()
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                            .transition(.opacity)
                    }
                }
                .frame(maxWidth: .infinity)
                .transition(.opacity)
            }
        }
#if !os(visionOS)
        .buttonStyle(ServiceUpgradeButtonStyle(isUnavailable: showNoUpgrades, animation: animation))
#else
        .tint(showNoUpgrades ? .gray : .accentColor)
#endif
        .disabled(isBusy || showNoUpgrades)
        .animation(animation, value: isBusy)
        .animation(animation, value: showNoUpgrades)
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
