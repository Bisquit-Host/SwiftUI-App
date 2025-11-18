import SwiftUI

#if canImport(Appearance)
import Appearance
#endif

struct DesignSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        Section("Design") {
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
        DesignSettings()
    }
    .darkSchemePreferred()
    .environmentObject(ValueStore())
}
