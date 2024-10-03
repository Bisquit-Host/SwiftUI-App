import SwiftUI

struct OtherSettings: View {
    @Environment(SettingsVM.self) private var vm
    @EnvironmentObject private var settings: SettingsStorage
    
    var body: some View {
        Section("Other") {
            BiometryButton()
                .environment(vm)
            
            Toggle(isOn: $settings.showFullFilePath) {
                Text("Full file path")
                
                Text(settings.showFullFilePath ? "/home/container/folder/example/" : "/folder/example/")
            }
            
            Button("Save all users to your contacts") {
                enableExtension()
            }
            
            CurrencyButton()
        }
        .listRowBackground(settings.transparentList ? .clear : Color.list)
    }
}

#Preview {
    OtherSettings()
        .environment(SettingsVM())
        .environmentObject(SettingsStorage())
}
