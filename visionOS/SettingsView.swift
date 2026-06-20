import SwiftUI
import BisquitoNet

struct SettingsView: View {
    @EnvironmentObject private var store: ValueStore
    
    @Binding private var user: BillingUser?
    
    init(_ user: Binding<BillingUser?>) {
        _user = user
    }
    
    var body: some View {
        VStack {
            Picker("Settings section", selection: $store.settingsSelectedTab) {
                Label("Account", systemImage: "person.crop.circle")
                    .tag(AppSettingsTab.account)
                
                Label("App", systemImage: "appclip")
                    .tag(AppSettingsTab.app)
                
                Label("Pterodactyl", systemImage: "externaldrive")
                    .tag(AppSettingsTab.pterodactyl)
            }
            .pickerStyle(.segmented)
            .scenePadding(.horizontal)
            
            Group {
                switch store.settingsSelectedTab {
                case .account: BillingSettings($user)
                case .app: AppSettings()
                case .pterodactyl: PterodactylSettings()
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .ornamentDismissButton()
    }
}

#Preview {
    @Previewable @State var user: BillingUser? = .preview
    
    SettingsView($user)
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
