import ScrechKit

struct OtherAppSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        BillingSectionCard("Other") {
            BiometryToggle()
            
            GlassyToggle(
                "Big ass animations",
                subtitle: "Pow + Vortex effects",
                icon: "sparkles",
                tint: .orange,
                isOn: $store.bigAssAnimations
            )
#if canImport(Appearance)
            AppSettingsAppearancePicker()
#endif
            GlassyActionCard("Change language", icon: "globe", tint: .blue) {
                openSettings()
            }
            
            GlassyNavLink("Debug", icon: "hammer", tint: .blue) {
                DebugSettings()
            }
        }
    }
}

#Preview {
    OtherAppSettings()
        .darkSchemePreferred()
}
