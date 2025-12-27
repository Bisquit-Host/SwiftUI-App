import ScrechKit

struct AppSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        ScrollView {
            AppIconSettings()
            CacheSettings()
            
            BillingSectionCard("Customization") {
#if canImport(Appearance)
                AppSettingsAppearancePicker()
#endif
            }
            
            BillingSectionCard("Other") {
                BiometryToggle()
                
                GlassyActionCard("Change language", icon: "globe", tint: .blue) {
                    openSettings()
                }
                
                GlassyNavLink("Debug", icon: "hammer", tint: .blue) {
                    DebugSettings()
                }
            }
        }
        .scrollIndicators(.never)
        .scenePadding(.horizontal)
    }
}

#Preview {
    AppSettings()
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
