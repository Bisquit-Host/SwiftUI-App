import SwiftUI
import OSLog

struct ServiceBillingSection<VM: ServiceBillingVMProtocol, ServiceDetailsVM: ServiceDetailsVMProtocol>: View {
    @Environment(VM.self) private var vm
    @Environment(ServiceDetailsVM.self) private var serviceDetailsVM
    @Environment(ConfettiVM.self) private var confetti
    @Environment(BiometryVM.self) private var biometry
    @Environment(DashboardVM.self) private var dashboardVM
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
    @State private var sheetTopup = false
    @State private var showTopupAlert = false
    
    var body: some View {
        @Bindable var vm = vm
        
        ServiceSectionCard("Billing") {
            ServiceExpiresIn(service.expiresAt)
            
            AutoRenewToggle(autorenewToggle: $autorenewToggle, syncedAutorenew: $syncedAutorenew, autorenew: autorenew, isPerformingAction: vm.isPerformingAction) { newValue in
                await vm.changeAutorenew(newValue, serviceId: service.id)
            }
            
            RenewButton(isPerformingAction: $vm.isPerformingAction, renewMonths: $renewMonths, name: vm.service?.name, confirmPayment: confirmRenewal)
            
            ServiceUpgradeButton<ServiceDetailsVM>()
        }
        .onAppear {
            showTopupAlert = vm.topupAlertContext == .serviceBilling
        }
        .onChange(of: vm.topupAlertContext) { _, newValue in
            showTopupAlert = newValue == .serviceBilling
        }
        .onChange(of: showTopupAlert) { _, newValue in
            if !newValue, vm.topupAlertContext == .serviceBilling {
                vm.topupAlertContext = nil
            }
        }
        .alert("Insufficient funds", isPresented: $showTopupAlert) {
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
