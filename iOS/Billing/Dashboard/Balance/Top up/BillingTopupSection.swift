import SwiftUI

struct BillingTopupSection: View {
    @Environment(SheetTopupVM.self) private var vm
    @Environment(BillingDashboardVM.self) private var dashboardVM
    @EnvironmentObject private var store: ValueStore
    
    @Binding var amount: String
    let providers: [PaymentProvider]
    @Binding var selectedProvider: PaymentProvider?
    let currency: BillingCurrency
    let minimumTopupAmount: Double
    
    private let amountFieldSide = 48.0
    
    private var minusDisabled: Bool {
        (Double(amount.replacingOccurrences(of: ",", with: ".")) ?? 0) <= minimumTopupAmount
    }
    
    @State private var safariCover = false
    @State private var paymentLink = ""
    var body: some View {
        BillingSectionCard("Top up") {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    TextField("Amount, \(currency.rawValue)", text: $amount)
                        .limitInputLength($amount, length: 10)
                        .keyboardType(.decimalPad)
                        .textInputAutocapitalization(.never)
                        .padding(12)
                        .background(.primary.opacity(0.04), in: .rect(cornerRadius: 12))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.primary.opacity(0.05), lineWidth: 1)
                        }
                        .frame(height: amountFieldSide)
                        .overlay {
                            Text(currency.symbol)
                                .secondary()
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.trailing)
                                .numericTransition()
                        }
                    
                    HStack(spacing: 8) {
                        Button {
                            adjustAmount(-currency.stepAmount)
                        } label: {
                            Image(systemName: "minus")
                                .frame(amountFieldSide)
                        }
                        .background(.primary.opacity(0.04), in: .rect(cornerRadius: 12))
                        .disabled(minusDisabled)
                        .opacity(minusDisabled ? 0.5 : 1)
                        
                        Button {
                            adjustAmount(currency.stepAmount)
                        } label: {
                            Image(systemName: "plus")
                                .frame(amountFieldSide)
                        }
                        .background(.primary.opacity(0.04), in: .rect(cornerRadius: 12))
                    }
                    .foregroundStyle(.foreground)
                    .frame(width: amountFieldSide * 2 + 8)
                }
                
                ScrollView(.horizontal) {
                    HStack(spacing: 10) {
                        ForEach(providers) {
                            TopupProviderCard(provider: $0, selectedProvider: $selectedProvider)
                        }
                    }
                }
                .scrollIndicators(.never)
                
                // Top-ups in other currencies are charged at 1.5× the converted amount in your default currency
                invoiceRow
                
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
        .safariCover($safariCover, url: paymentLink)
    }
    
    private func adjustAmount(_ delta: Double) {
        let normalized = amount.replacingOccurrences(of: ",", with: ".")
        let current = Double(normalized) ?? 0
        let updated = max(minimumTopupAmount, current + delta)
        
        amount = updated.formatted(.fractionDigits(2))
    }
    
    private func topUp() async {
        let normalizedAmount = amount.replacingOccurrences(of: ",", with: ".")
        
        guard let value = Double(normalizedAmount) else {
            SystemAlert.error("Invalid amount", subtitle: "Please enter a valid number")
            return
        }
        
        guard value >= minimumTopupAmount else {
            let minString = minimumTopupAmount.formatted(.fractionDigits(0))
            SystemAlert.error("Amount too small", subtitle: "Minimum top up is \(minString) \(currency.rawValue)")
            return
        }
        
        guard let provider = selectedProvider else {
            SystemAlert.error("Select a provider", subtitle: "Choose a payment method to continue")
            return
        }

        
        if let url = await vm.createTopup(amount: value, method: provider.method, currency: currency) {
            paymentLink = url.absoluteString
            safariCover = true
        }
    }
    
    private func invoiceValue() -> Double? {
        guard let amountDouble = Double(amount.replacingOccurrences(of: ",", with: ".")) else {
            return nil
        }
        
        switch currency {
        case .RUB: return amountDouble / 100 * 1.5
        case .EUR: return amountDouble * 100 / 1.5
        }
    }
    
    @ViewBuilder
    private var invoiceRow: some View {
        VStack(alignment: .leading, spacing: 6) {
            let amountDouble = Double(amount.replacingOccurrences(of: ",", with: "."))
            
            if let selectedProvider, let amountDouble {
                let differentCurrency = selectedProvider.currency != currency
                
                if differentCurrency, let invoice = invoiceValue() {
                    Text("\(selectedProvider.currency.symbol)\(invoice.formatted(.fractionDigits(2))) will be charged")
                } else {
                    Text("\(currency.symbol)\(amountDouble.formatted(.fractionDigits(2))) will be charged")
                }
            } else {
                Text("Enter amount to preview invoice")
            }
            
            Text("Additional fees may apply")
                .secondary()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .footnote()
        .padding(12)
        .background(.primary.opacity(0.04), in: .rect(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(.primary.opacity(0.05), lineWidth: 1)
        }
        .foregroundStyle(.primary.opacity(0.85))
    }
}
