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
        _amount = State(initialValue: String(format: "%.0f", SheetTopup.minimumAmount(for: user.currency)))
    }
    
    @State private var amount = ""
    
    var body: some View {
        ScrollView {
            VStack {
                BillingSectionCard("Balance") {
                    BillingBalanceRow("Main", icon: "creditcard.fill", tint: .blue, value: formatted(user.balance))
                    BillingBalanceRow("Bonus", icon: "gift", tint: .mint, value: formatted(user.bonusBalance))
                    
                    Divider()
                    
                    BillingBalanceRow("Total", icon: "wallet.pass.fill", tint: .indigo, value: formatted(user.totalBalance))
                }
                
                BillingTopupSection(
                    amount: $amount,
                    providers: providers,
                    selectedProvider: $selectedProvider,
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
