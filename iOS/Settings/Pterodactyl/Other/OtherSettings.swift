import SwiftUI

struct OtherSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        Section("Other") {
            BiometryButton()
            
            Toggle(isOn: $store.showFullFilePath) {
                Label("Full file path", systemImage: "folder")
                
                Text(store.showFullFilePath ? "/home/container/folder/example/" : "/folder/example/")
                    .footnote()
                    .animation(.default, value: store.showFullFilePath)
            }
            
            Toggle(isOn: $store.enableGameCenter) {
                Label("Game Center", systemImage: "gamecontroller")
            }
        }
    }
}

#Preview {
    List {
        OtherSettings()
    }
    .darkSchemePreferred()
    .environment(BiometryVM())
    .environmentObject(ValueStore())
}
