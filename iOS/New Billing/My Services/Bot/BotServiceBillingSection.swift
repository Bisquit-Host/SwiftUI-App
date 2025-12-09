import SwiftUI

struct BotServiceBillingSection: View {
    @Environment(BotServiceDetailVM.self) private var vm
    @Environment(BillingDashboardVM.self) private var dashboardVM
    
    @State private var renewMonths = 1
    @State private var lastRenewAmount: Double?
    @State private var alertRenew = false
    
    var body: some View {
        if let service = vm.service {
            BillingSectionCard("Billing") {
                Toggle(isOn: Binding(
                    get: { vm.service?.autorenew ?? service.autorenew },
                    set: { newValue in Task { await vm.changeAutorenew(newValue, serviceId: service.id) } }
                )) {
                    Text("Auto-extend monthly")
                }
                .toggleStyle(.switch)
                .disabled(vm.isPerformingAction)
                
                VStack(alignment: .leading, spacing: 8) {
                    Picker("Extend for", selection: $renewMonths) {
                        ForEach([1, 3, 6, 12], id: \.self) { value in
                            Text(value == 1 ? "1 month" : "\(value) months")
                                .tag(value)
                        }
                    }
                    .pickerStyle(.menu)
                    
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
                        Text("Charged \(formatCurrency(lastRenewAmount))")
                            .footnote()
                            .foregroundStyle(.green)
                    }
                }
            }
            .alert("Extend service", isPresented: $alertRenew) {
                Button("Confirm payment") {
                    guard let service = vm.service else { return }
                    
                    Task {
                        if let response = await vm.renew(months: renewMonths, serviceId: service.id) {
                            lastRenewAmount = response.amount
                        }
                    }
                }
                
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Extend \(vm.service?.name ?? "this service") for \(renewMonths) \(renewMonths == 1 ? "month" : "months")?")
            }
        }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        
        let value = formatter.string(from: NSNumber(value: amount)) ?? String(format: "%.2f", amount)
        
        if let user = dashboardVM.user {
            return user.currency.symbol + " " + value
        } else {
            return value
        }
    }
}
