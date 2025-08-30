import SwiftUI
import DeviceKit

struct DesignSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    @State private var imagePicker = false
    
    var body: some View {
        Section("Design") {
            Picker("Appearance", selection: $store.appearance) {
                ForEach(ColorTheme.allCases) { theme in
                    Text(theme.loc)
                        .tag(theme)
                }
            }
            
            Toggle("Compact server list", isOn: $store.compactServerList)
            
            Button {
                imagePicker = true
            } label: {
                HStack {
                    Text("Background image")
                    
                    Spacer()
                    
                    Image(systemName: "photo")
                        .secondary()
                }
            }
            .disabled(store.enableBisquitFall)
            .foregroundStyle(.foreground)
            .sheet($imagePicker) {
                NavigationStack {
                    BackgroundImagePickerView()
                }
            }
            
            Toggle("Animated background", isOn: $store.enableBisquitFall)
            
            if Device.current.hasDynamicIsland {
                Toggle("Dynamic Island badge", isOn: $store.showDynamicIslandBadge)
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
