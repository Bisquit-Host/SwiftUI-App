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
                GlassyActionCard("Change language", icon: "globe", tint: .purple) {
                    openSettings()
                }
                
                GlassyToggle("Game Center", icon: "gamecontroller", tint: .pink, isOn: $store.enableGameCenter)
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
        .environmentObject(ValueStore())
}
