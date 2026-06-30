import SwiftUI
import BisquitoNet

struct SettingsView: View {
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
            
            Tab("App", systemImage: "appclip", value: .app) {
                AppSettings()
            }
            
            Tab("Calagopus", systemImage: "externaldrive", value: .calagopus) {
                CalagopusSettings()
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    @Previewable @State var user: BillingUser? = .preview
    
    SettingsView($user)
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
