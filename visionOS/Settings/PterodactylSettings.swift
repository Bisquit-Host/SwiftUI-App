import SwiftUI

struct PterodactylSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        List {
            SettingsAccountSection()
            
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
        PterodactylSettings()
    }
    .environmentObject(ValueStore())
}
