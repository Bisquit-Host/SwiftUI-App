import SwiftUI

struct SheetTopup: View {
    @State private var vm = SheetTopupVM()
    @EnvironmentObject private var store: ValueStore
    
    private let user: BillingUser
    private let providers: [PaymentProvider]
    @State private var selectedProvider: PaymentProvider?
    
    init(_ user: BillingUser) {
        self.user = user
        let availableProviders = PaymentProvider.providers(for: user.currency)
        self.providers = availableProviders
        _selectedProvider = State(initialValue: availableProviders.first)
        _amount = State(initialValue: String(format: "%.0f", SheetTopup.minimumAmount(for: user.currency)))
    }
    
    @State private var amount = ""
    @State private var safariCover = false
    @State private var paymentLink = ""
    
    private let amountFieldSide: CGFloat = 48
    
    private var minusDisabled: Bool {
        (Double(amount.replacingOccurrences(of: ",", with: ".")) ?? 0) <= minimumTopupAmount
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                BillingSectionCard("Balance") {
                    BillingBalanceRow("Main", icon: "creditcard.fill", tint: .blue, value: formatted(user.balance))
                    BillingBalanceRow("Bonus", icon: "gift", tint: .mint, value: formatted(user.bonusBalance))
                    
                    Divider()
                    
                    BillingBalanceRow("Total", icon: "wallet.pass.fill", tint: .indigo, value: formatted(user.totalBalance))
                }
                
                BillingSectionCard("Top up") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 10) {
                            TextField("Amount, \(user.currency.rawValue)", text: $amount)
                                .keyboardType(.decimalPad)
                                .textInputAutocapitalization(.never)
                                .padding(12)
                                .background(.primary.opacity(0.04), in: .rect(cornerRadius: 12))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(.primary.opacity(0.05), lineWidth: 1)
                                }
                                .frame(height: amountFieldSide)
                            
                            HStack(spacing: 8) {
                                Button {
                                    adjustAmount(by: -user.currency.stepAmount)
                                } label: {
                                    Image(systemName: "minus")
                                        .frame(amountFieldSide)
                                }
                                .background(.primary.opacity(0.04), in: .rect(cornerRadius: 12))
                                .disabled(minusDisabled)
                                .opacity(minusDisabled ? 0.5 : 1)
                                
                                Button {
                                    adjustAmount(by: user.currency.stepAmount)
                                } label: {
                                    Image(systemName: "plus")
                                        .frame(amountFieldSide)
                                }
                                .background(.primary.opacity(0.04), in: .rect(cornerRadius: 12))
                            }
                            .foregroundStyle(.foreground)
                            .frame(width: amountFieldSide * 2 + 8)
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(providers) {
                                    TopupProviderCard($0, selectedProvider: $selectedProvider)
                                }
                            }
                        }
                        
                        Button {
                            Task {
                                await topUp()
                            }
                        } label: {
                            if vm.isTopupLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Top up")
                                    .foregroundStyle(.white)
                                    .rounded()
                                    .semibold()
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.top, 6)
                        .buttonStyle(.glassProminent)
                        .tint(.green)
                        .disabled(amount.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedProvider == nil || vm.isTopupLoading)
                    }
                }
                
                BillingOperationList(isLoading: vm.isLoading, operations: vm.operations)
            }
            .scenePadding()
        }
        .safariCover($safariCover, url: paymentLink)
        .refreshableTask {
            await vm.fetchOperations(accessToken: store.testAccessToken)
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                DismissButton()
            }
            
            ToolbarSpacer(.flexible, placement: .bottomBar)
        }
    }
    
    private func topUp() async {
        let normalizedAmount = amount.replacingOccurrences(of: ",", with: ".")
        
        guard let value = Double(normalizedAmount) else {
            SystemAlert.error("Invalid amount", subtitle: "Please enter a valid number")
            return
        }
        
        guard value >= minimumTopupAmount else {
            let minString = String(format: "%.0f", minimumTopupAmount)
            SystemAlert.error("Amount too small", subtitle: "Minimum top up is \(minString) \(user.currency.rawValue)")
            return
        }
        
        guard let provider = selectedProvider else {
            SystemAlert.error("Select a provider", subtitle: "Choose a payment method to continue")
            return
        }
        
        let token = store.testAccessToken
        
        if let url = await vm.createTopup(accessToken: token, amount: value, method: provider.method, currency: user.currency) {
            paymentLink = url.absoluteString
            safariCover = true
        }
    }
    
    private func adjustAmount(by delta: Double) {
        let normalized = amount.replacingOccurrences(of: ",", with: ".")
        let current = Double(normalized) ?? 0
        let updated = max(minimumTopupAmount, current + delta)
        
        amount = String(format: "%.2f", updated)
    }
    
    private var minimumTopupAmount: Double {
        SheetTopup.minimumAmount(for: user.currency)
    }
    
    private static func minimumAmount(for currency: BillingCurrency) -> Double {
        currency == .RUB ? 50 : 1
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
