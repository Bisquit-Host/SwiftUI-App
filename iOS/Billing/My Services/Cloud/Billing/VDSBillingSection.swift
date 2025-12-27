import SwiftUI

struct VDSBillingSection: View {
    @Environment(VDSServiceDetailsVM.self) private var vm
    @Environment(BillingDashboardVM.self) private var dashboardVM
    @Environment(ConfettiVM.self) private var confetti
    
    private let serviceId: Int
    private let autorenew: Bool
    private let expiresAt: Date?
    
    init(serviceId: Int, autorenew: Bool, expiresAt: Date?) {
        self.serviceId = serviceId
        self.autorenew = autorenew
        self.expiresAt = expiresAt
        
        _autorenewToggle = State(initialValue: autorenew)
        _syncedAutorenew = State(initialValue: autorenew)
    }
    
    @State private var autorenewToggle = false
    @State private var syncedAutorenew = false
    @State private var sheetUpgrade = false
    @State private var renewMonths = 1
    
    var body: some View {
        @Bindable var vm = vm
        
        VDSSectionCard("Billing") {
            ServiceExpiresIn(expiresAt)
            
            AutoRenewToggle(autorenewToggle: $autorenewToggle, syncedAutorenew: $syncedAutorenew, autorenew: autorenew, isPerformingAction: vm.isPerformingAction) { newValue in
                await vm.changeAutorenew(newValue, serviceId: serviceId)
            }
            
            RenewButton(isPerformingAction: $vm.isPerformingAction, renewMonths: $renewMonths, name: vm.service?.name, confirmPayment: confirmPayment)
            
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
        }
        .sheet($sheetUpgrade) {
            NavigationStack {
                VDSUpgradeSection(serviceId: serviceId)
            }
        }
    }
    
    private func confirmPayment() {
        guard let service = vm.service else { return }
        
        Task {
            if let response = await vm.renew(months: renewMonths, serviceId: service.id) {
                confetti.launchConfetti()
            }
        }
    }
}
