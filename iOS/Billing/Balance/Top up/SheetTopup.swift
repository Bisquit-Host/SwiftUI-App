import SwiftUI
import BisquitoNet

struct SheetTopup: View {
    @State private var vm = SheetTopupVM()
    
    private let user: BillingUser
    private let preselectedProviderID: String?
    @State private var selectedProvider: PaymentProvider?
    @State private var didApplyPreselectedProvider = false
    
    init(_ user: BillingUser, preselectedProviderID: String? = nil) {
        self.user = user
        self.preselectedProviderID = preselectedProviderID
        _amount = State(initialValue: formatCurrencyInput(user.currency.defaultTopupAmount, currency: user.currency))
    }
    
    @State private var amount = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                BillingSectionCard {
                    BillingBalanceCard("Total balance", value: formatted(user.totalBalance))
#if DEBUG
                    Divider()
                    BillingBalanceCard("Main balance", value: formatted(user.balance))
                    BillingBalanceCard("Bonus balance", value: formatted(user.bonusBalance))
#endif
                }
                
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
    
    private var minimumTopupAmount: Int64 {
        user.currency.minimumTopupAmount
    }
    
    private func formatted(_ amount: Int64) -> String {
        let formatter = NumberFormatter()
        
        formatter.numberStyle = .currency
        formatter.currencyCode = user.currency.rawValue
        formatter.minimumFractionDigits = user.currency.fractionDigits
        formatter.maximumFractionDigits = user.currency.fractionDigits
        
        let numerator = NSDecimalNumber(value: amount)
        let denominator = NSDecimalNumber(value: user.currency.scale)
        let number = numerator.dividing(by: denominator)
        
        return formatter.string(from: number) ?? formatCurrency(amount, user: user)
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
