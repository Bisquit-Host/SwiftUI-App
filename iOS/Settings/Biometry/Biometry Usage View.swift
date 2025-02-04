import ScrechKit

struct BiometryUsageView: View {
    @EnvironmentObject private var store: ValueStore
    
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
        .presentationBackground(store.transparentSheet ? .ultraThinMaterial : .regular)
    }
}

#Preview {
    BiometryUsageView()
        .environmentObject(ValueStore())
}
