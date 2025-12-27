import SwiftUI

struct VDSBillingSection: View {
    @Environment(VDSServiceDetailsVM.self) private var vm
    @Environment(BillingDashboardVM.self) private var dashboardVM
    @Environment(ConfettiVM.self) private var confetti
    
    let serviceId: Int
    let autorenew: Bool
    @Binding var renewMonths: Int
    let expiresAt: Date?
    
    @State private var autorenewToggle = false
    @State private var syncedAutorenew = false
    @State private var alertRenew = false
    @State private var sheetUpgrade = false
    @State private var lastRenewAmount: Double?
    
    init(serviceId: Int, autorenew: Bool, renewMonths: Binding<Int>, expiresAt: Date?) {
        self.serviceId = serviceId
        self.autorenew = autorenew
        _renewMonths = renewMonths
        self.expiresAt = expiresAt
        
        _autorenewToggle = State(initialValue: autorenew)
        _syncedAutorenew = State(initialValue: autorenew)
    }
    
    var body: some View {
        VDSSectionCard("Billing") {
            ServiceExpiresIn(expiresAt)
            
            AutoRenewToggle(autorenewToggle: $autorenewToggle, syncedAutorenew: $syncedAutorenew, autorenew: autorenew, isPerformingAction: vm.isPerformingAction) { newValue in
                await vm.changeAutorenew(newValue, serviceId: serviceId)
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
            
            if let lastRenewAmount {
                Text("Charged \(formatCurrency(lastRenewAmount, user: dashboardVM.user))")
                    .footnote()
                    .foregroundStyle(.green)
            }
        }
        .sheet($sheetUpgrade) {
            NavigationStack {
                VDSUpgradeSection(serviceId: serviceId)
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
