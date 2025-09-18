import SwiftUI

struct AppSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        List {
            
            
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
