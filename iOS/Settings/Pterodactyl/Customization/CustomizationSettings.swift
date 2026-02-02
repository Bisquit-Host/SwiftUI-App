import SwiftUI

struct CustomizationSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        BillingSectionCard("Customization") {
            ServerCardLayoutButton()
            BackgroundImageButton()
            GlassyToggle("Animated background", subtitle: "Performance aggressive", icon: "sparkles", tint: .yellow, isOn: $store.enableBisquitFall)
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
