import SwiftUI
import PteroNet

struct PterodactylSettings: View {
    @Environment(NavState.self) private var nav
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        List {
            Section {
                Button("Log out", role: .destructive) {
                    nav.clear()
                    store.isApiKeyValid = false
                    Keychain.delete(key: "selectedApiKey")
                }
            }
            
            DebugSettings()
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack {
        PterodactylSettings()
    }
    .darkSchemePreferred()
    .environment(NavState())
    .environmentObject(ValueStore())
}
