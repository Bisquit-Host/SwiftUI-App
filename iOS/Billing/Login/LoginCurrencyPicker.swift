import SwiftUI
import BisquitoNet

struct LoginCurrencyPicker: View {
    @Environment(LoginVM.self) private var vm
    
    var body: some View {
        @Bindable var vm = vm
        
        HStack {
            Text("Currency")
            
            Spacer(minLength: 100)
            
            Picker(selection: $vm.selectedCurrency) {
                ForEach(BillingCurrency.allCases, id: \.self) {
                    Text("\($0.displaySymbol) \($0.rawValue)")
                        .tag($0)
                }
            } label: {
                HStack(spacing: 6) {
                    Text("\(vm.selectedCurrency.displaySymbol) \(vm.selectedCurrency.rawValue)")
                    
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
