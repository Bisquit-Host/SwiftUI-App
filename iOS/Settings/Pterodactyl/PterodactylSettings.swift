import ScrechKit

struct PterodactylSettings: View {
    var body: some View {
        ScrollView {
            AccountSettings()
            CustomizationSettings()
            OtherSettings()
        }
        .scrollIndicators(.never)
        .scenePadding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        PterodactylSettings()
    }
    .darkSchemePreferred()
    .environmentObject(ValueStore())
}
