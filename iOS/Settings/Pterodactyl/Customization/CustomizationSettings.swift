import SwiftUI

#if canImport(Appearance)
import Appearance
#endif

struct CustomizationSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        BillingSectionCard("Customization") {
            BackgroundImageButton()
            ServerCardLayoutButton()
#if canImport(Appearance)
            AppearancePicker($store.appearance)
#endif
            GlassyToggle("Animated background", subtitle: "Performance aggressive" icon: "sparkles", tint: .yellow, isOn: $store.enableBisquitFall)
        }
    }
}

#Preview {
    List {
        CustomizationSettings()
    }
    .darkSchemePreferred()
    .environmentObject(ValueStore())
}
