import SwiftUI
import PteroNet

struct PluginCard: View {
    private let plugin: Plugin
    
    init(_ plugin: Plugin) {
        self.plugin = plugin
    }
    
    var body: some View {
        Text(plugin.name)
    }
}

//#Preview {
//    PluginCard()
//}
