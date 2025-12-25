import SwiftUI

struct TopupButton: View {
    @Environment(SheetTopupVM.self) private var vm
    
    let amount: String
    let currency: BillingCurrency
    let minimumTopupAmount: Double
    @Binding var selectedProvider: PaymentProvider?
    
    @State private var alertBeforePayment = false
    @State private var safariCover = false
    @State private var paymentLink = ""
    
    var body: some View {
        Button {
            alertBeforePayment = true
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
        .safariCover($safariCover, url: paymentLink)
        .alert(topupAlertTitle(), isPresented: $alertBeforePayment) {
            Button("Top up", role: .confirm) {
                Task {
                    await topUp()
                }
            }
            
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Additional fees may apply")
        }
    }
    
    private func topupAlertTitle() -> LocalizedStringKey {
        let amountDouble = Double(amount.replacingOccurrences(of: ",", with: "."))
        
        if let selectedProvider, let amountDouble {
            let differentCurrency = selectedProvider.currency != currency
            
            if differentCurrency, let invoice = invoiceValue() {
                return "\(selectedProvider.currency.symbol)\(invoice.formatted(.fractionDigits(2))) will be charged"
            } else {
                return "\(currency.symbol)\(amountDouble.formatted(.fractionDigits(2))) will be charged"
            }
        } else {
            return "Continue to payment"
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
}

//#Preview {
//    TopupSectionInvoiceRow()
//        .darkSchemePreferred()
//}
