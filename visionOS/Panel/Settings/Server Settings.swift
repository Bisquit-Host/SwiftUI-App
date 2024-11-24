import SwiftUI

struct ServerSettings: View {
    @EnvironmentObject private var settings: ValueStorage
    
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
