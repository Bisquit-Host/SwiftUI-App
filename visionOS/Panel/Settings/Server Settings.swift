import SwiftUI

struct ServerSettings: View {
    @EnvironmentObject private var settings: SettingsStorage
    
    @State private var test = false
    
    var body: some View {
        VStack {
            Text("Settings")
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    ServerSettings()
        .padding()
        .glassBackgroundEffect()
}
