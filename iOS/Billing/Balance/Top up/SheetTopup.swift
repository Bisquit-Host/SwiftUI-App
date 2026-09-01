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
        List {
            Section {
                SheetTopupBalance(user)
                    .scenePadding(.horizontal)
                    .listRowInsets(.init())
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .padding(.bottom)
            } footer: {
                TopupSection(
                    amount: $amount,
                    selectedProvider: $selectedProvider,
                    currency: user.currency,
                    billingUserID: user.id,
                    minimumTopupAmount: minimumTopupAmount,
                    showsPaymentProviderPicker: vm.showsPaymentProviderPicker
                )
                .foregroundStyle(.primary)
                .textCase(nil)
                .padding(.vertical)
            }
            .listSectionMargins(.horizontal, 0)
            
            BillingOperationList()
        }
        .navigationTitle("Finance stuff")
        .navigationBarTitleDisplayMode(.inline)
        .scrollIndicators(.hidden)
        .refreshableTask {
            async let operations = vm.fetchOperations()
            async let providers = vm.fetchProviders(currency: user.currency)
            async let userInfo = dashboardVM.fetchUserInfo()
            
            _ = await (operations, providers, userInfo)
        }
        .onChange(of: vm.providers) {
            updateSelectedProvider(for: vm.providers)
        }
        .onChange(of: vm.operations) {
            updateSelectedProvider(for: vm.providers)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                DismissButton()
            }
            
            if !vm.operations.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    RedeemButton()
                }
            }
        }
        .environment(vm)
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
