import SwiftUI

#if canImport(Appearance)
import Appearance
#endif

struct CustomizationSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        Section("Customization") {
            BackgroundImageButton()
            
            ServerCardLayoutButton()
            
#if canImport(Appearance)
            AppearancePicker($store.appearance)
#endif
            Toggle(isOn: $store.enableBisquitFall) {
                Label("Animated background", systemImage: "sparkles")
            }
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
