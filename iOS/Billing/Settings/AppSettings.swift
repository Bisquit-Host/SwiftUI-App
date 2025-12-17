import SwiftUI

struct AppSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    @Binding private var user: BillingUser?
    
    init(_ user: Binding<BillingUser?>) {
        _user = user
    }
    
    var body: some View {
        TabView(selection: $store.settingsSelectedTab) {
            Tab("Account", systemImage: "person.crop.circle", value: .account) {
                BillingSettings($user)
            }
            
            Tab("Pterodactyl", systemImage: "externaldrive", value: .pterodactyl) {
                
            }
            
            Tab("Debug", systemImage: "hammer", value: .debug) {
                
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

//#Preview {
//    AppSettings(.preview)
//        .darkSchemePreferred()
//        .environmentObject(ValueStore())
//}
