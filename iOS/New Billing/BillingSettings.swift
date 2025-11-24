import SwiftUI

struct BillingSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        List {
            Toggle("Test billing", isOn: $store.testBilling)
        }
    }
}

#Preview {
    BillingSettings()
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
