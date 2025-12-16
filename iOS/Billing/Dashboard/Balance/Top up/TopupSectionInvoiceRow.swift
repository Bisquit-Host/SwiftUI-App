import SwiftUI

struct TopupSectionInvoiceRow: View {
    let amount: String
    let currency: BillingCurrency
    @Binding var selectedProvider: PaymentProvider?
    
    var body: some View {
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
    
    private func invoiceValue() -> Double? {
        guard let amountDouble = Double(amount.replacingOccurrences(of: ",", with: ".")) else {
            return nil
        }
        
        switch currency {
        case .RUB: return amountDouble / 100 * 1.5
        case .EUR: return amountDouble * 100 / 1.5
        }
    }
}

//#Preview {
//    TopupSectionInvoiceRow()
//        .darkSchemePreferred()
//}
