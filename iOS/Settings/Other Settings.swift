import ScrechKit

struct OtherSettings: View {
    @Environment(SettingsVM.self) private var vm
    @EnvironmentObject private var settings: ValueStorage
    
    var body: some View {
        Section("Other") {
            BiometryButton()
                .environment(vm)
            
            Toggle(isOn: $settings.showFullFilePath) {
                Text("Full file path")
                
                Text(settings.showFullFilePath ? "/home/container/folder/example/" : "/folder/example/")
            }
            
            CurrencyButton()
            
            ListButton("Change language", actionIcon: "globe") {
                openSettings()
            }
        }
        .listRowBackground(settings.transparentList ? .clear : Color.list)
    }
}

#Preview {
    List {
        OtherSettings()
    }
    .environment(SettingsVM())
    .environmentObject(ValueStorage())
}
