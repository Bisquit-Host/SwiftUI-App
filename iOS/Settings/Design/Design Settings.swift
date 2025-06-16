import SwiftUI
import DeviceKit

struct DesignSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    @State private var animate = true
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
                NavigationView {
                    BackgroundImagePickerView()
                }
            }
            
            Picker("Color theme", selection: $store.colorTheme) {
                ForEach(ColorTheme.allCases) { theme in
                    Text(theme.localized)
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
