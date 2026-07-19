import ScrechKit
import BisquitoNet

struct SheetTopupBalance: View {
    @EnvironmentObject private var store: ValueStore

    private let user: BillingUser
    
    init(_ user: BillingUser) {
        self.user = user
    }
    
    private let balanceSize = 40.0
    
    var body: some View {
        VStack(spacing: 6) {
            Text("Total balance")
                .footnote(.semibold)
            
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(user.currency.displaySymbol)
                    .fontSize(balanceSize)
                    .secondary()
                
                let full = user.totalBalance / 100
                let cents = user.totalBalance % 100
                
                Text(full)
                    .fontSize(balanceSize)
                    .numericTransition(user.totalBalance)
                
                Text(".")
                    .fontSize(balanceSize)
                
                Text(cents, format: .number.precision(.integerLength(2)))
                    .fontSize(balanceSize / 2)
                    .numericTransition(user.totalBalance)
            }
            .bold()
            .animation(store.bigAssAnimations ? .default : nil, value: user.totalBalance)
        }
        .frame(maxWidth: .infinity)
        .rounded()
        .padding(.bottom)
    }
}

//#Preview {
//    SheetTopupBalance()
//}
