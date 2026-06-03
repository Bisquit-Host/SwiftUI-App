import SwiftUI
import BisquitoNet

struct TopupButton: View {
    @Environment(SheetTopupVM.self) private var vm
    
    let amount: String
    let currency: BillingCurrency
    let minimumTopupAmount: Int64
    @Binding var selectedProvider: PaymentProvider?
    
    @State private var safariCover = false
    @State private var paymentLink = ""
    
    var body: some View {
        Button {
            Task {
                await topUp()
            }
        } label: {
            Text("Top up")
                .foregroundStyle(.white)
                .rounded()
                .semibold()
                .frame(maxWidth: .infinity)
        }
        .padding(.top, 6)
#if !os(visionOS)
        .buttonStyle(.glassProminent)
#endif
        .tint(.green)
        .disabled(amount.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedProvider == nil || vm.isTopupLoading)
        .safariCover($safariCover, url: paymentLink)
    }
    
    private func topUp() async {
        guard let value = parseCurrencyInput(amount, currency: currency) else {
            SystemAlert.error("Invalid amount", subtitle: "Please enter a valid number")
            return
        }
        
        guard value >= minimumTopupAmount else {
            let minString = formatCurrencyValue(
                minimumTopupAmount,
                currency: currency,
                minimumFractionDigits: 0,
                maximumFractionDigits: currency.fractionDigits
            )
            
            SystemAlert.error("Amount too small", subtitle: "Minimum top up is \(minString) \(currency.rawValue)")
            return
        }
        
        guard let provider = selectedProvider else {
            SystemAlert.error("Select a provider", subtitle: "Choose a payment method to continue")
            return
        }
        
        if let url = await vm.createTopup(amount: value, gatewayId: provider.id, currency: currency) {
            paymentLink = url.absoluteString
            safariCover = true
        }
    }
}

//#Preview {
//    TopupSectionInvoiceRow()
//        .darkSchemePreferred()
//}
