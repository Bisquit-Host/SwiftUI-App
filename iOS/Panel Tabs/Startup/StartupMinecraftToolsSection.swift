import SwiftUI

struct StartupMinecraftToolsSection: View {
    let modVM: MinecraftModInstallerVM
    let pluginVM: MinecraftPluginInstallerVM
    let modpackVM: MinecraftModpackInstallerVM
    
    let showModManager: () -> Void
    let showPluginManager: () -> Void
    let showModpackInstaller: () -> Void
    
    var body: some View {
        Section("Minecraft tools") {
            toolButton(
                title: "Mod manager",
                subtitle: modSubtitle,
                icon: "shippingbox.fill",
                tint: .orange,
                available: modVM.minecraftModManagerAvailable,
                action: showModManager
            )
            
            toolButton(
                title: "Plugin manager",
                subtitle: pluginSubtitle,
                icon: "puzzlepiece.fill",
                tint: .blue,
                available: pluginVM.minecraftPluginManagerAvailable,
                action: showPluginManager
            )
            
            toolButton(
                title: "Modpack installer",
                subtitle: modpackSubtitle,
                icon: "square.stack.3d.up.fill",
                tint: .mint,
                available: modpackVM.minecraftModpackInstallerAvailable,
                action: showModpackInstaller
            )
        }
        .listRowBackground(Color.gray.opacity(0.2))
    }
    
    var modSubtitle: String {
        if !modVM.minecraftModManagerAvailable {
            return "Unavailable"
        }
        
        if modVM.installedMinecraftMods.isEmpty {
            return "No installed mods"
        }
        
        return "Installed: \(modVM.installedMinecraftMods.count)"
    }
    
    var pluginSubtitle: String {
        if !pluginVM.minecraftPluginManagerAvailable {
            return "Unavailable"
        }
        
        if pluginVM.installedMinecraftPlugins.isEmpty {
            return "No installed plugins"
        }
        
        return "Installed: \(pluginVM.installedMinecraftPlugins.count)"
    }
    
    var modpackSubtitle: String {
        if !modpackVM.minecraftModpackInstallerAvailable {
            return "Unavailable"
        }
        
        guard let installed = modpackVM.mostRecentInstalledMinecraftModpack else {
            return "No tracked modpack"
        }
        
        return "Installed: \(installed.name)"
    }
    
    func toolButton(
        title: String,
        subtitle: String,
        icon: String,
        tint: Color,
        available: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundStyle(.white)
                    .frame(28)
                    .background(tint, in: .circle)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .subheadline(.semibold)
                    
                    Text(subtitle)
                        .caption()
                        .secondary()
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .secondary()
                    .footnote()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(.rect)
            .opacity(available ? 1 : 0.7)
        }
        .foregroundStyle(.foreground)
        .buttonStyle(.plain)
    }
}

#Preview {
    let modVM = MinecraftModInstallerVM("")
    let pluginVM = MinecraftPluginInstallerVM("")
    let modpackVM = MinecraftModpackInstallerVM("")
    
    List {
        StartupMinecraftToolsSection(
            modVM: modVM,
            pluginVM: pluginVM,
            modpackVM: modpackVM,
            showModManager: {},
            showPluginManager: {},
            showModpackInstaller: {}
        )
    }
    .darkSchemePreferred()
}
