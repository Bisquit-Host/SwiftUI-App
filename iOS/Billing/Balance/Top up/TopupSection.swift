import SwiftUI
import BisquitoNet

struct TopupSection: View {
    @Environment(SheetTopupVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    @Binding var amount: String
    @Binding var selectedProvider: PaymentProvider?
    let providers: [PaymentProvider]
    let currency: BillingCurrency
    let minimumTopupAmount: Int64
    
    private let amountFieldSide = 48.0
    
    private var minusDisabled: Bool {
        (parseCurrencyInput(amount, currency: currency) ?? 0) <= minimumTopupAmount
    }
    
    var body: some View {
        BillingSectionCard {
            BillingSectionCard("Top up") {
                HStack(spacing: 10) {
                    TextField("Amount, \(currency.rawValue)", text: $amount)
                        .limitInputLength($amount, length: 10)
                        .keyboardType(.decimalPad)
                        .textInputAutocapitalization(.never)
                        .monospacedDigit()
                        .padding(12)
                        .background(.primary.opacity(0.04), in: .rect(cornerRadius: 12))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.primary.opacity(0.05), lineWidth: 1)
                        }
                        .frame(height: amountFieldSide)
                        .overlay {
                            Text(currency.displaySymbol)
                                .secondary()
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.trailing)
                                .numericTransition()
                        }
                    
                    HStack(spacing: 8) {
                        Button {
                            adjustAmount(-currency.stepAmountMinor)
                        } label: {
                            Image(systemName: "minus")
                                .frame(amountFieldSide)
                        }
                        .background(.primary.opacity(0.04), in: .rect(cornerRadius: 12))
                        .disabled(minusDisabled)
                        .opacity(minusDisabled ? 0.5 : 1)
                        
                        Button {
                            adjustAmount(currency.stepAmountMinor)
                        } label: {
                            Image(systemName: "plus")
                                .frame(amountFieldSide)
                        }
                        .background(.primary.opacity(0.04), in: .rect(cornerRadius: 12))
                    }
                    .foregroundStyle(.foreground)
                    .frame(width: amountFieldSide * 2 + 8)
                }
                
                TopupProviderList($selectedProvider, providers: providers)
                
                TopupButton(amount: amount, currency: currency, minimumTopupAmount: minimumTopupAmount, selectedProvider: $selectedProvider)
                
                ORDivider()
                
                RedeemButton()
            }
        }
    }
    
    private func adjustAmount(_ delta: Int64) {
        let current = parseCurrencyInput(amount, currency: currency) ?? 0
        let updated = max(minimumTopupAmount, current + delta)
        
        amount = formatCurrencyInput(updated, currency: currency)
    }
}
