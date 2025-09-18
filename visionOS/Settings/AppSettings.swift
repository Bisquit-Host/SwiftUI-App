import SwiftUI

struct AppSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        List {
            Toggle(isOn: $store.devMode) {
                Label("Developer mode", systemImage: "hammer")
            }
            
            Toggle(isOn: $store.enableGameCenter) {
                Label("Game Center", systemImage: "gamecontroller")
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
