import ScrechKit

struct OtherAppSettings: View {
    var body: some View {
        BillingSectionCard("Other") {
            BiometryToggle()
            
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
