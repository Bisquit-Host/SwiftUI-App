import ScrechKit

struct PterodactylSettings: View {
    var body: some View {
        ScrollView {
            AccountSettings()
#if !os(visionOS)
            CustomizationSettings()
#endif
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
