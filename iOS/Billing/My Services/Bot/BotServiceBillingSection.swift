import SwiftUI

struct BotServiceBillingSection: View {
    @Environment(BotServiceDetailsVM.self) private var vm
    @Environment(BillingDashboardVM.self) private var dashboardVM
    
    private let service: BillingBotServiceDetails
    
    init(_ service: BillingBotServiceDetails) {
        self.service = service
        _autorenew = State(initialValue: service.autorenew)
        _syncedAutorenew = State(initialValue: service.autorenew)
    }
    
    @State private var renewMonths = 1
    @State private var autorenew = false
    @State private var syncedAutorenew = false
    @State private var lastRenewAmount: Double?
    @State private var alertRenew = false
    
    var body: some View {
        BillingSectionCard("Billing") {
            Toggle(isOn: $autorenew) {
                Text("Auto-extend monthly")
            }
            .toggleStyle(.switch)
            .disabled(vm.isPerformingAction)
            .task(id: service.autorenew) {
                syncedAutorenew = service.autorenew
                autorenew = service.autorenew
            }
            .onChange(of: autorenew) { _, newValue in
                guard newValue != syncedAutorenew else { return }
                
                Task {
                    await vm.changeAutorenew(newValue, serviceId: service.id)
                    
                    let actualValue = vm.service?.autorenew ?? service.autorenew
                    await MainActor.run {
                        syncedAutorenew = actualValue
                        autorenew = actualValue
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ExtendMonthsAmountPicker($renewMonths)
                
                Button {
                    alertRenew = true
                } label: {
                    if vm.isPerformingAction {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Pay and extend")
                            .semibold()
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(vm.isPerformingAction)
                
                if let expires = service.expiresAt {
                    Text("Expires \(expires.formatted(date: .numeric, time: .shortened))")
                        .footnote()
                        .secondary()
                }
                
                if let lastRenewAmount {
                    Text("Charged \(formatCurrency(lastRenewAmount, user: dashboardVM.user))")
                        .footnote()
                        .foregroundStyle(.green)
                }
            }
        }
        .alert("Extend service", isPresented: $alertRenew) {
            Button("Confirm payment", role: .confirm, action: confirmPayment)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Extend \(vm.service?.name ?? "this service") for \(renewMonths) \(renewMonths == 1 ? "month" : "months")?")
        }
    }
    
    private func confirmPayment() {
        guard let service = vm.service else { return }
        
        Task {
            if let response = await vm.renew(months: renewMonths, serviceId: service.id) {
                lastRenewAmount = response.amount
            }
        }
    }
}
