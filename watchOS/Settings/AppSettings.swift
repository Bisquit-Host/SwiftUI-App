import SwiftUI
import PteroNet

struct AppSettings: View {
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
        AppSettings()
    }
    .darkSchemePreferred()
    .environment(NavState())
    .environmentObject(ValueStore())
}
