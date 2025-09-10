import SwiftUI

#warning("Empty")
struct ServerSettings: View {
    @State private var test = false
    
    var body: some View {
        List {
            
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack {
        ServerSettings()
    }
    .padding()
    .glassBackgroundEffect()
}
