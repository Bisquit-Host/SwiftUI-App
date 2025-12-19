import SwiftUI

struct PterodactylSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        List {
            SettingsAccountSection()
            
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
