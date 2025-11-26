import SwiftUI

struct BillingAccountSection: View {
    private let user: BillingUser
    
    init(_ user: BillingUser) {
        self.user = user
    }
    
    var body: some View {
        BillingSectionCard("Account") {
            BillingAccountRow("Email", icon: "envelope.fill", tint: .blue, value: user.email) {
                
            }
            
            BillingAccountRow("Name", icon: "person.fill", tint: .cyan, value: user.name) {
                
            }
            
            BillingAccountRow("Language", icon: "character.cursor.ibeam", tint: .mint, value: user.lang.uppercased()) {
                
            }
            
            BillingAccountRow("Currency", icon: "dollarsign", tint: .yellow, value: user.currency)
        }
    }
}

#Preview {
    BillingAccountSection(.preview)
}
