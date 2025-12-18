import SwiftUI

struct OtherSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        BillingSectionCard("Other") {
            BiometryButton()
            
            Toggle(isOn: $store.showFullFilePath) {
                Label("Full file path", systemImage: "folder")
                
                Text(store.showFullFilePath ? "/home/container/folder/example/" : "/folder/example/")
                    .footnote()
                    .animation(.default, value: store.showFullFilePath)
            }
            
            GlassyToggle("Game Center", icon: "gamecontroller", tint: .pink, isOn: $store.enableGameCenter)
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
