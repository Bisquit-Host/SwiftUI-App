import SwiftUI

struct CurrencyPicker: View {
    @EnvironmentObject private var store: ValueStore
    
    private let currencies = ["₽", "€"]
    
    var body: some View {
        HStack {
            Text("Preferred currency")
            
            Spacer()
            
            Picker("Preferred currency", selection: $store.preferredCurrency) {
                ForEach(currencies, id: \.self) {
                    Text($0)
                        .tag($0)
                }
            }
            .frame(width: 120)
            .pickerStyle(.segmented)
        }
    }
}

#Preview {
    List {
        CurrencyPicker()
    }
    .environmentObject(ValueStore())
}
