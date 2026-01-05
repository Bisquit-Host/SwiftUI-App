import SwiftUI
import BisquitoNet

struct LoginCurrencyPicker: View {
    @Binding private var selectedCurrency: BillingCurrency
    
    init(_ selectedCurrency: Binding<BillingCurrency>) {
        _selectedCurrency = selectedCurrency
    }
    
    var body: some View {
        HStack {
            Text("Currency")
            
            Spacer(minLength: 100)
            
            Picker(selection: $selectedCurrency) {
                ForEach(BillingCurrency.allCases, id: \.self) {
                    Text("\($0.symbol) \($0.rawValue)")
                        .tag($0)
                }
            } label: {
                HStack(spacing: 6) {
                    Text("\(selectedCurrency.symbol) \(selectedCurrency.rawValue)")
                    
                    Image(systemName: "chevron.up.chevron.down")
                        .footnote()
                        .secondary()
                }
            }
            .pickerStyle(.segmented)
            .tint(.primary)
        }
        .loginButtonStyle()
    }
}
