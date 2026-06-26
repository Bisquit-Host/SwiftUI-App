import SwiftUI

struct PluginLoaderPicker: View {
    @Binding var pluginLoader: String
    
    let pluginLoaderOptions: [String]
    
    private let fallbackPluginLoaders = [
        "paper", "spigot", "bukkit", "purpur", "folia",
        "velocity", "waterfall", "bungeecord", "sponge"
    ]
    
    var body: some View {
        HStack {
            Text("Plugin loader")
            
            Spacer()
            
            Picker("Plugin loader", selection: $pluginLoader) {
                Text("Any")
                    .tag("")
                
                ForEach(displayedPluginLoaders, id: \.self) { loader in
                    Text(loader.capitalized)
                        .tag(loader)
                }
            }
            .pickerStyle(.menu)
            .tint(.primary)
        }
    }
    
    private var displayedPluginLoaders: [String] {
        if pluginLoaderOptions.isEmpty {
            fallbackPluginLoaders
        } else {
            pluginLoaderOptions
        }
    }
}
