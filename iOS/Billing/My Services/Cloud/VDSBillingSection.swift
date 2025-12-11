import SwiftUI

struct VDSBillingSection: View {
    @Environment(VDSServiceDetailsVM.self) private var vm
    
    let serviceId: Int
    let autorenew: Bool
    @Binding var renewMonths: Int
    let expiresAt: Date?
    let formatCurrency: (Double) -> String
    
    @State private var alertRenew = false
    @State private var lastRenewAmount: Double?
    
    var body: some View {
        BillingSectionCard("Billing") {
            Toggle(isOn: Binding(
                get: { autorenew },
                set: { newValue in Task { await vm.changeAutorenew(newValue, serviceId: serviceId) } }
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
                
                if let expiresAt {
                    Text("Expires \(expiresAt.formatted(date: .numeric, time: .shortened))")
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
