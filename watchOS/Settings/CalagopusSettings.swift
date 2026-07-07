import SwiftUI

struct CalagopusSettings: View {
    var body: some View {
        List {
            DebugSettings()
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack {
        CalagopusSettings()
    }
    .darkSchemePreferred()
    .environment(NavState())
}
