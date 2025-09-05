import SwiftUI
import DeviceKit

struct DesignSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    @State private var sheetServerCardLayout = false
    
    var body: some View {
        Section("Design") {
            BackgroundImageButton()
            
            Button {
                sheetServerCardLayout = true
            } label: {
                Label {
                    Text("Server card layout")
                } icon: {
                    Image(systemName: "externaldrive")
                        .foregroundStyle(.blue)
                }
            }
            .foregroundStyle(.foreground)
            .sheet($sheetServerCardLayout) {
                NavigationStack {
                    ServerCardLayout()
                }
            }
            
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
