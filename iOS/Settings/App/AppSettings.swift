import ScrechKit

struct AppSettings: View {
    var body: some View {
        ScrollView {
            AppIconSettings()
            CacheSettings()
            
            BillingSectionCard("Other") {
                GlassyActionCard("Change language", icon: "globe", tint: .purple) {
                    openSettings()
                }
            }
            
            DebugSettings()
        }
        .scrollIndicators(.never)
        .scenePadding(.horizontal)
    }
}

#Preview {
    AppSettings()
        .darkSchemePreferred()
}
