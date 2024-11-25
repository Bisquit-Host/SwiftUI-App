import SwiftUI
import DeviceKit

struct DesignSettings: View {
    @EnvironmentObject private var settings: ValueStorage
    
    @State private var animate = true
    
    var body: some View {
        Section("Design") {
            if Device.current.hasDynamicIsland {
                Toggle("Show Dynamic Island badge", isOn: $settings.showDynamicIslandBadge)
            }
            
            Toggle("Transparent sheets", isOn: $settings.transparentSheet)
            
            Toggle("Transparent lists", isOn: $settings.transparentList)
            
            Toggle("Bisquit waterfall", isOn: $settings.enableBisquitFall)
        }
        .listRowBackground(settings.transparentList ? .clear : Color.list)
    }
}

#Preview {
    List {
        DesignSettings()
    }
    .environmentObject(ValueStorage())
}
