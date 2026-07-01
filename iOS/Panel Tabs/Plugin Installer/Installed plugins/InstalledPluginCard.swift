import SwiftUI
import Calagopus

struct InstalledPluginCard: View {
    @Environment(PluginInstallerVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    let plugin: MinecraftInstalledProject
    let canUpdate: (MinecraftInstalledProject) -> Bool
    let installUpdate: (MinecraftInstalledProject) -> Void
    
    @State private var confirmDelete = false
    
    var body: some View {
        HStack(spacing: 10) {
            MinecraftCatalogIcon(plugin.iconURL, placeholderSystemImage: "puzzlepiece.fill")
            
            VStack(alignment: .leading, spacing: 2) {
                Text(plugin.projectName ?? plugin.fileName)
                    .lineLimit(2)
                
                InstalledMinecraftProjectMetadata(
                    version: plugin.installedVersionDisplayName,
                    provider: PluginProvider(providerValue: plugin.provider)?.name ?? plugin.providerDisplayName
                )
            }
            
            Spacer()
            
            if canUpdate(plugin) {
                Button("Update", systemImage: "square.and.arrow.down") {
                    installUpdate(plugin)
                }
                .title3(.semibold)
                .buttonBorderShape(.circle)
                .labelStyle(.iconOnly)
                .disabled(vm.isInstallingPlugin)
                .padding(.trailing)
                .tint(.orange)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .backgroundStyling(store.panelSidebarBackgroundStyle, in: .rect(cornerRadius: 16))
        .contentShape(.rect(cornerRadius: 16))
        .contentShape(.contextMenuPreview, .rect(cornerRadius: 16))
        .contextMenu {
            Button("Delete", systemImage: "trash", role: .destructive) {
                confirmDelete = true
            }
            .disabled(vm.isInstallingPlugin)
        }
        .confirmationDialog(
            "Delete \(plugin.projectName ?? plugin.fileName)?",
            isPresented: $confirmDelete,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive, action: deletePlugin)
        }
    }
    
    private func deletePlugin() {
        Task {
            await vm.removeInstalledPlugin(plugin)
        }
    }
}

//#Preview {
//    InstalledPluginCard()
//}
