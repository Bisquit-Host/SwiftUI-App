import ScrechKit

struct BiometryUsageView: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        NavigationStack {
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
    }
}

#Preview {
    BiometryUsageView()
        .environmentObject(ValueStore())
}
