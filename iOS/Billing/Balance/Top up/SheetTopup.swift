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
        _amount = State(initialValue: formatCurrencyInput(user.currency.minimumTopupAmount, currency: user.currency))
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
}

#Preview {
    SheetTopup(.preview)
        .environmentObject(ValueStore())
        .darkSchemePreferred()
}
