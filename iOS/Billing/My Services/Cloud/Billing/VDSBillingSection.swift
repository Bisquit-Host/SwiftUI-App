import ScrechKit
import SwiftUI

struct VDSBillingSection: View {
    @Environment(VDSServiceDetailsVM.self) private var vm
    @Environment(BillingDashboardVM.self) private var dashboardVM
    
    let serviceId: Int
    let autorenew: Bool
    @Binding var renewMonths: Int
    let expiresAt: Date?
    
    @State private var autorenewToggle = false
    @State private var syncedAutorenew = false
    @State private var alertRenew = false
    @State private var alertRenewInfo = false
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
            if let expiresAt {
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
            
            Toggle(isOn: $autorenewToggle) {
                HStack(spacing: 5) {
                    Text("Auto-renew")
                    
                    SFButton("questionmark.circle.fill") {
                        alertRenewInfo = true
                    }
                    .footnote()
                    .secondary()
                }
            }
            .toggleStyle(.switch)
            .disabled(vm.isPerformingAction)
            .subheadline()
            .task(id: autorenew) {
                syncedAutorenew = autorenew
                autorenewToggle = autorenew
            }
            .onChange(of: autorenewToggle) { _, newValue in
                guard newValue != syncedAutorenew else { return }
                
                Task {
                    await vm.changeAutorenew(newValue, serviceId: serviceId)
                    
                    let actualValue = vm.service?.autorenew ?? autorenew
                    syncedAutorenew = actualValue
                    autorenewToggle = actualValue
                }
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
        .alert("Auto-renew", isPresented: $alertRenewInfo) {
            
        } message: {
            Text("Automatically charges the one-month amount from your billing balance, not from your bank account")
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
