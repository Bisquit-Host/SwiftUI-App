import SwiftUI

struct SheetTopup: View {
    private let user: BillingUser
    
    init(_ user: BillingUser) {
        self.user = user
    }
    
    var body: some View {
        List {
            Section {
                Text("Balance \(user.balance, specifier: "%.2f")")
                Text("Bonus balance \(user.bonusBalance, specifier: "%.2f")")
                Text("Total balance \(user.totalBalance, specifier: "%.2f")")
            }
            
            Text("Top up")
        }
    }
}

struct BillingOperation {
    let total: Int
}

#Preview {
    SheetTopup(.preview)
        .darkSchemePreferred()
}
