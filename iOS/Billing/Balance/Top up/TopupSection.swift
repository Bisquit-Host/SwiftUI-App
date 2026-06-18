import ScrechKit
import BisquitoNet

struct TopupSection: View {
    @Environment(SheetTopupVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    @Binding var amount: String
    @Binding var selectedProvider: PaymentProvider?
    let currency: BillingCurrency
    let minimumTopupAmount: Int64
    let showsPaymentProviderPicker: Bool
    
    private let amountFieldSide = 48.0
    
    private var minusDisabled: Bool {
        (parseCurrencyInput(amount, currency: currency) ?? 0) <= minimumTopupAmount
    }
    
    private var isAppStoreSelected: Bool {
        selectedProvider?.isAppStore == true
    }
    
    var body: some View {
        BillingSectionCard("Top up") {
            if isAppStoreSelected {
                TopupAppStoreProductView()
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.primary.opacity(0.04), in: .rect(cornerRadius: 12))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.primary.opacity(0.05), lineWidth: 1)
                    }
            } else {
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
            }
            
            if showsPaymentProviderPicker {
                TopupProviderList($selectedProvider, providers: vm.providers)
            }
            
            if !isAppStoreSelected {
                TopupButton(amount: amount, currency: currency, minimumTopupAmount: minimumTopupAmount, selectedProvider: $selectedProvider)
            }
#if DEBUG
            ORDivider()
            RedeemButton()
#endif
        }
    }
    
    private func adjustAmount(_ delta: Int64) {
        let current = parseCurrencyInput(amount, currency: currency) ?? 0
        let updated = max(minimumTopupAmount, current + delta)
        
        amount = formatCurrencyInput(updated, currency: currency)
    }
}
