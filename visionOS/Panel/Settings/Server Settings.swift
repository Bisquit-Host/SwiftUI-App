import SwiftUI

struct ServerSettings: View {
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
