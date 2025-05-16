import SwiftUI

struct AppSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            Toggle("Developer mode", isOn: $store.devMode)
            
            Toggle("Game Center", isOn: $store.enableGameCenter)
        }
        .padding()
        .navigationTitle("Settings")
        .ornamentDismissButton()
    }
}

#Preview {
    AppSettings()
        .environmentObject(ValueStore())
        .padding()
        .glassBackgroundEffect()
}
