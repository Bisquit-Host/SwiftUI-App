import SwiftUI

struct CurrencyButton: View {
    @EnvironmentObject private var settings: SettingsStorage
    
    private let currencies = ["₽", "€", "$"]
    
    var body: some View {
        HStack {
            Text("Preferred currency")
            
            Spacer()
            
            Picker("Preferred currency", selection: $settings.preferredCurrency) {
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
