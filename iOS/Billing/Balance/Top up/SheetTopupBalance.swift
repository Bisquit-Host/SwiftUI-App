import ScrechKit
import BisquitoNet

struct SheetTopupBalance: View {
#if DEBUG
    @EnvironmentObject private var store: ValueStore
#endif
    private let user: BillingUser
    
    init(_ user: BillingUser) {
        self.user = user
    }
    
    private let balanceSize = 40.0
    
    var body: some View {
#if DEBUG
        let balance = store.overrideBillingBalance ? 6_416 : user.totalBalance
        let currency: BillingCurrency = store.overrideBillingBalance ? .EUR : user.currency
#else
        let balance = user.totalBalance
        let currency = user.currency
#endif
        VStack(spacing: 6) {
            Text("Total balance")
                .subheadline(.semibold)
                .secondary()
            
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(currency.displaySymbol)
                    .fontSize(balanceSize)
                    .secondary()
                
                let full = balance / 100
                let cents = balance % 100
                
                Text(full)
                    .fontSize(balanceSize)
                    .numericTransition(balance)
                
                Text(".")
                    .fontSize(balanceSize)
                
                Text(cents, format: .number.precision(.integerLength(2)))
                    .fontSize(balanceSize / 2)
                    .numericTransition(balance)
            }
            .bold()
            .animation(.default, value: balance)
        }
        .frame(maxWidth: .infinity)
        .rounded()
    }
}

//#Preview {
//    SheetTopupBalance()
//}
