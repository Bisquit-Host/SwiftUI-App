import SwiftUI
import DeviceKit

struct DesignSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    @State private var animate = true
    
    var body: some View {
        Section("Design") {
            Picker("Color theme", selection: $store.colorTheme) {
                ForEach(ColorTheme.allCases) { theme in
                    Text(theme.rawValue.capitalized)
                        .tag(theme)
                }
            }
            
            if Device.current.hasDynamicIsland {
                Toggle("Dynamic Island badge", isOn: $store.showDynamicIslandBadge)
            }
            
            Toggle("Transparent sheets", isOn: $store.transparentSheet)
            
            Toggle("Transparent lists", isOn: $store.transparentList)
            
            Toggle("Bisquit waterfall", isOn: $store.enableBisquitFall)
        }
        .listRowBackground(store.transparentList ? .clear : Color.list)
    }
}

#Preview {
    List {
        DesignSettings()
    }
    .environmentObject(ValueStore())
}
