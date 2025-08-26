import ScrechKit

struct BiometryUsageView: View {
    var body: some View {
        #warning("Needed here?")
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
}
