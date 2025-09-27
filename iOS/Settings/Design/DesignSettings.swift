import SwiftUI
import DeviceKit

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
            
            if Device.current.hasDynamicIsland {
                Toggle(isOn: $store.showDynamicIslandBadge) {
                    Label("Dynamic Island badge", systemImage: "iphone")
                }
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
