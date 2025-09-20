import SwiftUI
import SwiftData
import PteroNet

struct AppSettings: View {
    @Environment(NavState.self) private var navState
    @EnvironmentObject private var store: ValueStore
    
    @Query(animation: .default) private var keys: [APIKey]
    
    @State private var sheetKeyStorage = false
    
    var body: some View {
        List {
            Section {
                if keys.count > 0 {
                    Button("Switch account", systemImage: "arrow.trianglehead.2.clockwise.rotate.90") {
                        sheetKeyStorage = true
                    }
                }
                
                Button("Log out", systemImage: "rectangle.portrait.and.arrow.right", role: .destructive) {
                    navState.clear()
                    store.isApiKeyValid = false
                    Keychain.delete(key: "selectedApiKey")
                }
                .foregroundStyle(.red)
            }
            
            Toggle(isOn: $store.enableGameCenter) {
                Label("Game Center", systemImage: "gamecontroller")
            }
            
            Section("Debug") {
                Toggle(isOn: $store.devMode) {
                    Label("Developer mode", systemImage: "hammer")
                }
            }
        }
        .navigationTitle("Settings")
        .padding()
        .ornamentDismissButton()
    }
}

#Preview {
    NavigationStack {
        AppSettings()
    }
    .environmentObject(ValueStore())
}
