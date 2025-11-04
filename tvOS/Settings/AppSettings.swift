import ScrechKit
import PteroNet

struct AppSettings: View {
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
            
            Button("API-key Creation") {
                sheetGuide = true
            }
            
            ListLink("Configurations", icon: "externaldrive.badge.plus") {
                PlanViewParent()
            }
            
            Section {
                Button("Log out", systemImage: "rectangle.portrait.and.arrow.right", role: .destructive) {
                    dismiss()
                    nav.clear()
                    store.isApiKeyValid = false
                    Keychain.delete(key: "selectedApiKey")
                }
            }
            
            DevSettings()
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
        AppSettings()
    }
    .darkSchemePreferred()
    .environmentObject(ValueStore())
    .environment(NavState())
}
