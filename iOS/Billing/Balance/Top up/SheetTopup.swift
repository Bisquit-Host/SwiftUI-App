import SwiftUI
import BisquitoNet

struct SheetTopup: View {
    @Environment(DashboardVM.self) private var dashboardVM
    @State private var vm = SheetTopupVM()
    
    private let initialUser: BillingUser
    private let preselectedProviderID: String?
    @State private var selectedProvider: PaymentProvider?
    @State private var didApplyPreselectedProvider = false
    
    init(_ user: BillingUser, preselectedProviderID: String? = nil) {
        initialUser = user
        self.preselectedProviderID = preselectedProviderID
        _amount = State(initialValue: formatCurrencyInput(user.currency.defaultTopupAmount, currency: user.currency))
    }
    
    @State private var amount = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                SheetTopupBalance(user)
                
                TopupSection(
                    amount: $amount,
                    selectedProvider: $selectedProvider,
                    currency: user.currency,
                    minimumTopupAmount: minimumTopupAmount,
                    showsPaymentProviderPicker: vm.showsPaymentProviderPicker
                )
                
                BillingOperationList()
            }
            .scenePadding()
        }
        .navigationTitle("Finance stuff")
        .navigationBarTitleDisplayMode(.inline)
        .scrollIndicators(.never)
        .environment(vm)
        .refreshableTask {
            await vm.fetchOperations()
            await vm.fetchProviders(currency: user.currency)
            await dashboardVM.fetchUserInfo()
        }
        .onChange(of: vm.providers) {
            updateSelectedProvider(for: vm.providers)
        }
        .onChange(of: vm.operations) {
            updateSelectedProvider(for: vm.providers)
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                DismissButton()
            }
#if !os(visionOS)
            ToolbarSpacer(.flexible, placement: .bottomBar)
#endif
        }
    }

    private var user: BillingUser {
        dashboardVM.user ?? initialUser
    }
    
    private var minimumTopupAmount: Int64 {
        user.currency.minimumTopupAmount
    }
    
    private func updateSelectedProvider(for providers: [PaymentProvider]) {
        guard !providers.isEmpty else {
            selectedProvider = nil
            return
        }
        
        if !vm.showsPaymentProviderPicker {
            selectedProvider = providers.first(where: \.isAppStore) ?? .appStore(currency: user.currency)
            return
        }
        
        if !didApplyPreselectedProvider, let preselectedProviderID, let matched = providers.first(where: { $0.id == preselectedProviderID }) {
            selectedProvider = matched
            didApplyPreselectedProvider = true
            return
        }
        
        if let selectedProvider, let matched = providers.first(where: { $0.id == selectedProvider.id }) {
            self.selectedProvider = matched
            return
        }
        
        selectedProvider = providers.first
    }
}

#Preview {
    SheetTopup(.preview)
        .environment(DashboardVM())
        .environmentObject(ValueStore())
        .darkSchemePreferred()
}
