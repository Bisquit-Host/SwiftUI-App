import SwiftUI
import Calagopus

struct InstalledModCard: View {
    @Environment(ModInstallerVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    private let mod: MinecraftInstalledProject
    private let canUpdate: (MinecraftInstalledProject) -> Bool
    private let installUpdate: (MinecraftInstalledProject) -> Void
    
    @State private var confirmDelete = false
    
    init(
        _ mod: MinecraftInstalledProject,
        canUpdate: @escaping (MinecraftInstalledProject) -> Bool,
        installModUpdate: @escaping (MinecraftInstalledProject) -> Void
    ) {
        self.mod = mod
        self.canUpdate = canUpdate
        self.installUpdate = installModUpdate
    }
    
    var body: some View {
        HStack(spacing: 10) {
            MinecraftCatalogIcon(mod.iconURL, placeholderSystemImage: "shippingbox.fill")
            
            VStack(alignment: .leading, spacing: 2) {
                Text(mod.projectName ?? mod.path)
                    .subheadline()
                    .lineLimit(2)
                
                InstalledMinecraftProjectMetadata(
                    version: mod.installedVersionDisplayName,
                    provider: ModManagerProvider(providerValue: mod.provider)?.name ?? mod.providerDisplayName
                )
            }
            
            Spacer()
            
            if canUpdate(mod) {
                Button("Update", systemImage: "square.and.arrow.down") {
                    installUpdate(mod)
                }
                .title3(.semibold)
                .buttonBorderShape(.circle)
                .labelStyle(.iconOnly)
                .disabled(vm.isInstallingMod)
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
            .disabled(vm.isLoadingInstalledMods)
        }
        .confirmationDialog(
            "Delete \(mod.projectName ?? mod.path)?",
            isPresented: $confirmDelete,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive, action: deleteMod)
        }
    }
    
    private func deleteMod() {
        Task {
            await vm.removeInstalledMod(mod)
        }
    }
}

//#Preview {
//    InstalledModCard()
//}
