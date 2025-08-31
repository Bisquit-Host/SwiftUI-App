import ScrechKit

struct OtherSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        Section("Other") {
            BiometryButton()
            
            Toggle(isOn: $store.showFullFilePath) {
                Label("Full file path", systemImage: "folder")
                
                Text(store.showFullFilePath ? "/home/container/folder/example/" : "/folder/example/")
                    .footnote()
            }
            
            Toggle(isOn: $store.enableGameCenter) {
                Label("Game Center", systemImage: "gamecontroller")
            }
            
            Button {
                openSettings()
            } label: {
                Label {
                    Text("Change language")
                } icon: {
                    Image(systemName: "globe")
                        .foregroundStyle(.blue)
                }
                .foregroundStyle(.foreground)
            }
            
            CurrencyPicker()
        }
    }
}

#Preview {
    List {
        OtherSettings()
    }
    .environment(BiometryVM())
    .environmentObject(ValueStore())
}
