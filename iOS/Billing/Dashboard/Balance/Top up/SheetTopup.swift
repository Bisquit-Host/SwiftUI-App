import SwiftUI

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
        _amount = State(initialValue: SheetTopup.minimumAmount(for: user.currency).formatted(.fractionDigits(2)))
    }
    
    @State private var amount = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                BillingSectionCard("Balance") {
                    BillingBalanceCard("Main", value: formatted(user.balance))
                    BillingBalanceCard("Bonus", value: formatted(user.bonusBalance))
                    
                    Divider()
                    
                    BillingBalanceCard("Total", value: formatted(user.totalBalance))
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
        }
        .scenePadding()
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
            
            ToolbarSpacer(.flexible, placement: .bottomBar)
        }
    }
    
    private var minimumTopupAmount: Double {
        SheetTopup.minimumAmount(for: user.currency)
    }
    
    private static func minimumAmount(for currency: BillingCurrency) -> Double {
        currency == .RUB ? 50 : 5
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
