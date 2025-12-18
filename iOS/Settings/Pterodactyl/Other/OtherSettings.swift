import SwiftUI

struct OtherSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        BillingSectionCard("Other") {
            BiometryButton()
            
            GlassyToggle("Full file path", subtitle: store.showFullFilePath ? "/home/container/folder/example/" : "/folder/example/", icon: "folder", tint: .pink, isOn: $store.showFullFilePath)
            
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
