import SwiftUI

struct ServiceBillingSection<VM: ServiceBillingVMProtocol>: View {
    @Environment(VM.self) private var vm
    @Environment(ConfettiVM.self) private var confetti
    @Environment(BiometryVM.self) private var biometry
    @EnvironmentObject private var store: ValueStore
    
    private let service: BillingServiceDetails
    private let autorenew: Bool
    
    init(_ service: BillingServiceDetails) {
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
            
            RenewButton(isPerformingAction: $vm.isPerformingAction, renewMonths: $renewMonths, name: vm.service?.name, confirmPayment: confirmRenewal)
        }
    }
    
    private func confirmRenewal() {
        Task {
            guard let service = vm.service else { return }
            
            if store.useBiometry, await !biometry.authenticate() {
                SystemAlert.error("Biometry authentication failed")
                return
            }
            
            if let response = await vm.renew(months: renewMonths, serviceId: service.id) {
                print(response)
                confetti.launchConfetti()
            }
        }
    }
}

extension GameServiceDetailsVM: ServiceBillingVMProtocol {}
extension BotServiceDetailsVM: ServiceBillingVMProtocol {}
