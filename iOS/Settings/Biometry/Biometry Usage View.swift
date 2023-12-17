import ScrechKit

struct BiometryUsageView: View {
    @EnvironmentObject private var settings: SettingsStorage
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Biometry usage description")
                    .rounded()
            }
            .padding()
            .navigationTitle("Biometry Usage")
            .toolbarTitleDisplayMode(.inline)
        }
        .monospaced()
        .presentationDetents([.medium])
        .presentationBackground(settings.transparentSheet ? .ultraThinMaterial : .regular)
    }
}

#Preview {
    BiometryUsageView()
        .environmentObject(SettingsStorage())
}
