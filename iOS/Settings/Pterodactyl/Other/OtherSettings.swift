import SwiftUI

struct OtherSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        BillingSectionCard("Other") {
            GlassyToggle("Full file path", subtitle: store.showFullFilePath ? "/home/container/folder/example/" : "/folder/example/", icon: "folder", tint: .blue, isOn: $store.showFullFilePath)
        }
    }
}

#Preview {
    List {
        OtherSettings()
    }
    .darkSchemePreferred()
    .environmentObject(ValueStore())
}
