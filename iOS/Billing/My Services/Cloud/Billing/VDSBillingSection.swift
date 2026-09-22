import SwiftUI
import OSLog

struct VDSBillingSection: View {
    @Environment(VDSServiceDetailsVM.self) private var vm
    @Environment(DashboardVM.self) private var dashboardVM
    @Environment(ConfettiVM.self) private var confetti
    @Environment(BiometryVM.self) private var biometry
    @EnvironmentObject private var store: ValueStore
    
    private let service: CloudServiceDetails?
    
    init(_ service: CloudServiceDetails?) {
        self.service = service
        _autorenewToggle = State(initialValue: service?.autorenew ?? false)
        _syncedAutorenew = State(initialValue: service?.autorenew ?? false)
    }
    
    @State private var autorenewToggle = false
    @State private var syncedAutorenew = false
    @State private var renewMonths = 1
    @State private var sheetTopup = false
    @State private var alertTopup = false
    
    var body: some View {
        @Bindable var vm = vm
        
        ServiceSectionCard("Billing") {
            LabeledContent("Price") {
                Text(formatCurrency(service?.price ?? 1000, user: dashboardVM.user))
                    .redacted(reason: service == nil ? .placeholder : [])
            }
            .subheadline()
            
            ServiceExpiresIn(service == nil ? .now.addingTimeInterval(30 * 24 * 60 * 60) : service?.expiresAt)
                .redacted(reason: service == nil ? .placeholder : [])
            
            AutoRenewToggle(autorenewToggle: $autorenewToggle, syncedAutorenew: $syncedAutorenew, autorenew: service?.autorenew ?? false, isPerformingAction: vm.isPerformingAction) { newValue in
                guard let service else { return }
                await vm.changeAutorenew(newValue, serviceId: service.id)
            }
            
            RenewButton(isPerformingAction: $vm.isPerformingAction, renewMonths: $renewMonths, name: vm.service?.name, confirmPayment: confirmRenewal)
            
            VDSBillingSectionUpgradeButton(service?.id ?? 0)
        }
        .disabled(service == nil)
        .onAppear {
            alertTopup = vm.topupAlertContext == .serviceBilling
        }
        .onChange(of: vm.topupAlertContext) { _, newValue in
            alertTopup = newValue == .serviceBilling
        }
        .onChange(of: alertTopup) { _, newValue in
            if !newValue, vm.topupAlertContext == .serviceBilling {
                vm.topupAlertContext = nil
            }
        }
        .alert("Insufficient funds", isPresented: $alertTopup) {
            Button("Dismiss", role: .cancel) {}
            
            Button("Top up") {
                vm.topupAlertContext = nil
                sheetTopup = true
            }
        } message: {
            Text("Add funds to continue")
        }
        .sheet($sheetTopup) {
            NavigationStack {
                if let user = dashboardVM.user {
                    SheetTopup(user)
                        .environment(dashboardVM)
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
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
                Logger().info("Renew response: \(String(describing: response))")
                confetti.launchConfetti()
            }
        }
    }
}
