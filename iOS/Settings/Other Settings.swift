import ScrechKit

struct OtherSettings: View {
    @Environment(SettingsVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        Section("Other") {
            BiometryButton()
                .environment(vm)
            
            Toggle(isOn: $store.showFullFilePath) {
                Text("Full file path")
                
                Text(store.showFullFilePath ? "/home/container/folder/example/" : "/folder/example/")
            }
            
            CurrencyButton()
            
            ListButton("Change language", actionIcon: "globe") {
                openSettings()
            }
        }
        .listRowBackground(store.transparentList ? .clear : Color.list)
    }
}

#Preview {
    List {
        OtherSettings()
    }
    .environment(SettingsVM())
    .environmentObject(ValueStore())
}
