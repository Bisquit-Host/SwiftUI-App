import SwiftUI
import Calagopus

struct InstalledPluginCard: View {
    @Environment(PluginInstallerVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    let plugin: MinecraftInstalledProject
    let canUpdate: (MinecraftInstalledProject) -> Bool
    let installPluginUpdate: (MinecraftInstalledProject) -> Void
    
    var body: some View {
        HStack(spacing: 10) {
            MinecraftCatalogIcon(
                plugin.iconURL,
                placeholderSystemImage: "puzzlepiece.fill",
                size: 44,
                cornerRadius: 8
            )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(plugin.projectName ?? plugin.fileName)
                    .lineLimit(2)
                
                InstalledMinecraftProjectMetadataView(
                    version: plugin.installedVersionDisplayName,
                    provider: PluginProvider(providerValue: plugin.provider)?.name ?? plugin.providerDisplayName
                )
            }
            
            Spacer()
            
            if canUpdate(plugin) {
                Button("Update", systemImage: "square.and.arrow.down") {
                    installPluginUpdate(plugin)
                }
                .semibold()
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .labelStyle(.iconOnly)
                .disabled(vm.isInstallingPlugin)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .backgroundStyling(store.panelSidebarBackgroundStyle, in: .rect(cornerRadius: 16))
    }
}

//#Preview {
//    InstalledPluginCard()
//}
