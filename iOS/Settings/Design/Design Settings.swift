import SwiftUI
import DeviceKit

struct DesignSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    @State private var imagePicker = false
    
    var body: some View {
        Section("Design") {
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
            
            Picker("Appearance", selection: $store.appearance) {
                ForEach(ColorTheme.allCases) { theme in
                    Text(theme.loc)
                        .tag(theme)
                }
            }
            
            if Device.current.hasDynamicIsland {
                Toggle("Dynamic Island badge", isOn: $store.showDynamicIslandBadge)
            }
            
            Toggle("Animated background", isOn: $store.enableBisquitFall)
        }
    }
}

#Preview {
    List {
        DesignSettings()
    }
    .environmentObject(ValueStore())
}
