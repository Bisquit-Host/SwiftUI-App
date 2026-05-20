import SwiftUI

struct InstalledPluginCard: View {
    @Environment(PluginInstallerVM.self) private var vm
    
    let plugin: MinecraftInstalledProject
    let canUpdate: (MinecraftInstalledProject) -> Bool
    let installPluginUpdate: (MinecraftInstalledProject) -> Void
    
    var body: some View {
        HStack(spacing: 10) {
            MinecraftCatalogIcon(
                plugin.iconURL,
                placeholderSystemImage: "puzzlepiece.fill",
                size: 22,
                cornerRadius: 6
            )
            
            Text(plugin.fileName)
                .lineLimit(2)
            
            Spacer()
            
            if canUpdate(plugin) {
                Button("Update") {
                    installPluginUpdate(plugin)
                }
                .footnote(.semibold)
                .tint(.yellow)
                .disabled(vm.isInstallingPlugin)
            }
        }
    }
}

//#Preview {
//    InstalledPluginCard()
//}
