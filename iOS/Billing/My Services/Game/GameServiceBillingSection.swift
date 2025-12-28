import SwiftUI

struct GameServiceBillingSection: View {
    @Environment(GameServiceDetailsVM.self) private var vm
    @Environment(BillingDashboardVM.self) private var dashboardVM
    @Environment(ConfettiVM.self) private var confetti
    
    private let service: BillingGameServiceDetails
    private let autorenew: Bool
    
    init(_ service: BillingGameServiceDetails) {
        self.service = service
        self.autorenew = service.autorenew
        _autorenewToggle = State(initialValue: service.autorenew)
        _syncedAutorenew = State(initialValue: service.autorenew)
    }
    
    @State private var renewMonths = 1
    @State private var autorenewToggle = false
    @State private var syncedAutorenew = false
    
    var body: some View {
        @Bindable var vm = vm
        
        BillingSectionCard("Billing") {
            ServiceExpiresIn(service.expiresAt)
            
            AutoRenewToggle(autorenewToggle: $autorenewToggle, syncedAutorenew: $syncedAutorenew, autorenew: autorenew, isPerformingAction: vm.isPerformingAction) { newValue in
                await vm.changeAutorenew(newValue, serviceId: service.id)
            }
            
            RenewButton(isPerformingAction: $vm.isPerformingAction, renewMonths: $renewMonths, name: vm.service?.name, confirmPayment: confirmPayment)
        }
    }
    
    private func confirmPayment() {
        Task {
            guard let service = vm.service else { return }
            
            if let response = await vm.renew(months: renewMonths, serviceId: service.id) {
                print(response)
                confetti.launchConfetti()
            }
        }
    }
}
