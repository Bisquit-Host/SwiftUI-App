import ScrechKit

struct CalagopusSettings: View {
    var body: some View {
        List {
            DebugSettingsSection()
        }
        .navigationTitle("Settings")
        .listStyle(.grouped)
    }
}

#Preview {
    NavigationStack {
        CalagopusSettings()
    }
    .darkSchemePreferred()
}
