import ScrechKit
import Calagopus

struct PterodactylSettings: View {
    @Environment(NavState.self) private var nav
    @EnvironmentObject private var store: ValueStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var sheetKeyStorage = false
    @State private var sheetGuide = false
    @State private var apiKey = Keychain.load(key: "selectedApiKey") ?? ""
    
    var body: some View {
        List {
            Button("Switch account", systemImage: "arrow.trianglehead.2.clockwise.rotate.90") {
                sheetKeyStorage = true
            }
            
            Button("API key Creation") {
                sheetGuide = true
            }
            
            Section {
                Button("Log out", systemImage: "rectangle.portrait.and.arrow.right", role: .destructive) {
                    dismiss()
                    nav.clear()
                    store.isApiKeyValid = false
                    Keychain.delete(key: "selectedApiKey")
                }
            }
            
            DebugSettingsSection()
        }
        .navigationTitle("Settings")
        .listStyle(.grouped)
        .sheet($sheetKeyStorage) {
            CloudKeysParent($apiKey)
        }
        .fullScreenCover($sheetGuide) {
            Guide()
                .background(.ultraThinMaterial)
        }
    }
}

#Preview {
    NavigationStack {
        PterodactylSettings()
    }
    .darkSchemePreferred()
    .environmentObject(ValueStore())
    .environment(NavState())
}
