import SwiftUI

struct CurrencyPicker: View {
    @EnvironmentObject private var store: ValueStore
    
    private let currencies = ["₽", "€"]
    
    var body: some View {
        HStack {
            Text("Preferred currency")
            
            Spacer()
            
            Picker("Preferred currency", selection: $store.preferredCurrency) {
                ForEach(currencies, id: \.self) { currency in
                    Text(currency)
                        .tag(currency)
                }
            }
            .frame(width: 120)
            .pickerStyle(.segmented)
        }
    }
}
