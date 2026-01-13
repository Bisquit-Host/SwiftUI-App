import SwiftUI
import BisquitoNet

struct SheetTopup: View {
    @State private var vm = SheetTopupVM()
    
    private let user: BillingUser
    private let providers: [PaymentProvider]
    @State private var selectedProvider: PaymentProvider?
    
    init(_ user: BillingUser) {
        self.user = user
        
        let availableProviders = PaymentProvider.allCases
        self.providers = availableProviders
        
        _selectedProvider = State(initialValue: availableProviders.first)
        _amount = State(initialValue: minimumAmount(for: user.currency).formatted(.fractionDigits(2)))
    }
    
    @State private var amount = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                BillingSectionCard {
                    BillingBalanceCard("Total balance", value: formatted(user.totalBalance))
                    
                    Divider()
                    
                    BillingBalanceCard("Main", value: formatted(user.balance))
                    BillingBalanceCard("Bonus", value: formatted(user.bonusBalance))
                }
                
                TopupSection(
                    amount: $amount,
                    selectedProvider: $selectedProvider,
                    providers: providers,
                    currency: user.currency,
                    minimumTopupAmount: minimumTopupAmount
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
    
    private var minimumTopupAmount: Double {
        minimumAmount(for: user.currency)
    }
    
    private func minimumAmount(for currency: BillingCurrency) -> Double {
        switch currency {
        case .EUR: 1
        case .RUB: 50
        }
    }
    
    private func formatted(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        
        formatter.numberStyle = .currency
        formatter.currencyCode = user.currency.rawValue
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        return formatter.string(from: amount as NSNumber) ?? "\(amount)"
    }
}

#Preview {
    SheetTopup(.preview)
        .environmentObject(ValueStore())
        .darkSchemePreferred()
}
