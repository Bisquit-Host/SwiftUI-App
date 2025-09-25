import SwiftUI
import DeviceKit

struct DesignSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        Section("Design") {
            BackgroundImageButton()
            
            ServerCardLayoutButton()
            
            Picker(selection: $store.appearance) {
                ForEach(ColorTheme.allCases) {
                    Text($0.loc)
                        .tag($0)
                }
            } label: {
                Label("Appearance", systemImage: "paintbrush")
            }
            
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
