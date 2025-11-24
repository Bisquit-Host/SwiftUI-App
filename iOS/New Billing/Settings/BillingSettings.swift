import SwiftUI

struct BillingSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        List {
            Section("Debug") {
                Toggle("Test billing", isOn: $store.testBilling)
                
                Button("Log out") {
                    store.testAccessToken = ""
                }
            }
        }
    }
}

#Preview {
    BillingSettings()
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
