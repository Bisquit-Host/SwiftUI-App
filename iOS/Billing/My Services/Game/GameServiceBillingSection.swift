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
    @State private var lastRenewAmount: Double?
    @State private var alertRenew = false
    
    var body: some View {
        BillingSectionCard("Billing") {
            if let expiresAt = service.expiresAt {
                LabeledContent {
                    VStack(alignment: .trailing) {
                        let expireDate = expiresAt.formatted(date: .numeric, time: .shortened)
                        let daysLeft = Calendar.current.dateComponents([.day], from: Date(), to: expiresAt).day ?? 0
                        
                        Text(expireDate)
                        
                        if daysLeft > 0 {
                            Text("in \(daysLeft) days")
                                .footnote()
                                .tertiary()
                        }
                    }
                } label: {
                    Text("Expires")
                }
                .subheadline()
            }
            
            AutoRenewToggle(autorenewToggle: $autorenewToggle, syncedAutorenew: $syncedAutorenew, autorenew: autorenew, isPerformingAction: vm.isPerformingAction) { newValue in
                await vm.changeAutorenew(newValue, serviceId: service.id)
            }
            
            HStack(spacing: 5) {
                Button {
                    alertRenew = true
                } label: {
                    if vm.isPerformingAction {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Renew for")
                            .semibold()
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.glassProminent)
                .disabled(vm.isPerformingAction)
                
                ExtendMonthsAmountPicker($renewMonths)
            }
            .padding(8)
            .background(.ultraThinMaterial, in: .capsule)
            
            if let lastRenewAmount {
                Text("Charged \(formatCurrency(lastRenewAmount, user: dashboardVM.user))")
                    .footnote()
                    .foregroundStyle(.green)
            }
        }
        .alert("Renew service", isPresented: $alertRenew) {
            Button("Confirm payment", role: .confirm, action: confirmPayment)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Renew \(vm.service?.name ?? "this service") for \(renewMonths) \(renewMonths == 1 ? "month" : "months")?")
        }
    }
    
    private func confirmPayment() {
        guard let service = vm.service else { return }
        
        Task {
            if let response = await vm.renew(months: renewMonths, serviceId: service.id) {
                confetti.launchConfetti()
                lastRenewAmount = response.amount
            }
        }
    }
}
