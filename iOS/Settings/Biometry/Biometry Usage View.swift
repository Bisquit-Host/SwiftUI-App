import ScrechKit

struct BiometryUsageView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Biometry usage description")
                    .monospaced()
                    .rounded()
            }
            .navigationTitle("Biometry Usage")
            .toolbarTitleDisplayMode(.inline)
            .padding()
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    BiometryUsageView()
}
