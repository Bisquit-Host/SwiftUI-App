import SwiftUI

struct StartupMinecraftToolsSection: View {
    @Environment(StartupVM.self) private var vm
    
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
                available: vm.minecraftModManagerAvailable,
                action: showModManager
            )
            
            toolButton(
                title: "Plugin manager",
                subtitle: pluginSubtitle,
                icon: "puzzlepiece.fill",
                tint: .blue,
                available: vm.minecraftPluginManagerAvailable,
                action: showPluginManager
            )
            
            toolButton(
                title: "Modpack installer",
                subtitle: modpackSubtitle,
                icon: "square.stack.3d.up.fill",
                tint: .mint,
                available: vm.minecraftModpackInstallerAvailable,
                action: showModpackInstaller
            )
        }
        .listRowBackground(Color.gray.opacity(0.2))
    }
    
    var modSubtitle: String {
        if !vm.minecraftModManagerAvailable {
            return "Unavailable"
        }
        
        if vm.installedMinecraftMods.isEmpty {
            return "No installed mods"
        }
        
        return "Installed: \(vm.installedMinecraftMods.count)"
    }
    
    var pluginSubtitle: String {
        if !vm.minecraftPluginManagerAvailable {
            return "Unavailable"
        }
        
        if vm.installedMinecraftPlugins.isEmpty {
            return "No installed plugins"
        }
        
        return "Installed: \(vm.installedMinecraftPlugins.count)"
    }
    
    var modpackSubtitle: String {
        if !vm.minecraftModpackInstallerAvailable {
            return "Unavailable"
        }
        
        guard let installed = vm.installedMinecraftModpack else {
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
                    .frame(width: 28, height: 28)
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
            .opacity(available ? 1 : 0.7)
        }
        .foregroundStyle(.foreground)
        .buttonStyle(.plain)
    }
}

#Preview {
    List {
        StartupMinecraftToolsSection(
            showModManager: {},
            showPluginManager: {},
            showModpackInstaller: {}
        )
    }
    .darkSchemePreferred()
    .environment(StartupVM(""))
}
