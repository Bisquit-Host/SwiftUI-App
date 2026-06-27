import SwiftUI

struct PluginLoaderPicker: View {
    @Environment(PluginInstallerVM.self) private var vm
    
    @Binding var pluginLoader: String
    
    private let fallbackPluginLoaders = [
        "paper", "spigot", "bukkit", "purpur", "folia",
        "velocity", "waterfall", "bungeecord", "sponge"
    ]
    
    var body: some View {
        HStack {
            Text("Plugin loader")
            
            Spacer()
            
            Picker("Plugin loader", selection: $pluginLoader) {
                Text("All")
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
        if vm.pluginLoaderOptions.isEmpty {
            fallbackPluginLoaders
        } else {
            vm.pluginLoaderOptions
        }
    }
}
