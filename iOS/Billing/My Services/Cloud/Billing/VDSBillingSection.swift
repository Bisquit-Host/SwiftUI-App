import SwiftUI

struct VDSBillingSection: View {
    @Environment(VDSServiceDetailsVM.self) private var vm
    @Environment(BillingDashboardVM.self) private var dashboardVM
    
    let serviceId: Int
    let autorenew: Bool
    @Binding var renewMonths: Int
    let expiresAt: Date?
    
    @State private var alertRenew = false
    @State private var sheetUpgrade = false
    @State private var lastRenewAmount: Double?
    
    var body: some View {
        VDSSectionCard("Billing") {
            if let expiresAt {
                LabeledContent("Expires", value: expiresAt.formatted(date: .numeric, time: .shortened))
            }
            
            Toggle(isOn: Binding(
                get: { autorenew },
                set: { newValue in Task { await vm.changeAutorenew(newValue, serviceId: serviceId) } }
            )) {
                Text("Auto-renew")
                
                Text("Will charge the one-month amount from your billing balance, not from your bank account")
                    .footnote()
            }
            .toggleStyle(.switch)
            .disabled(vm.isPerformingAction)
            
            HStack {
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
                
                Picker("Renew for", selection: $renewMonths) {
                    ForEach([1, 3, 6, 12], id: \.self) {
                        Text($0 == 1 ? "1 month" : "\($0) months")
                            .tag($0)
                    }
                }
                .pickerStyle(.menu)
                .tint(.primary)
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
            .padding(8)
            
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
