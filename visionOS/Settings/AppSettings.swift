import SwiftUI

struct AppSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        List {
            Toggle("Developer mode", isOn: $store.devMode)
            
            Toggle("Game Center", isOn: $store.enableGameCenter)
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
