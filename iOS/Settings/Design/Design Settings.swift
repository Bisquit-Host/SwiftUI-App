import SwiftUI
import DeviceKit

struct DesignSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        Section("Design") {
            Picker(selection: $store.appearance) {
                ForEach(ColorTheme.allCases) {
                    Text($0.loc)
                        .tag($0)
                }
            } label: {
                Label("Appearance", systemImage: "paintbrush")
            }
            
            Toggle(isOn: $store.compactServerList) {
                Label("Compact server list", systemImage: "rectangle.compress.vertical")
            }
            
            BackgroundImageButton()
            
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
    .environmentObject(ValueStore())
}
