import SwiftUI
import Calagopus

struct InstalledModCard: View {
    @Environment(ModInstallerVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    private let mod: MinecraftInstalledProject
    private let canUpdate: (MinecraftInstalledProject) -> Bool
    private let installModUpdate: (MinecraftInstalledProject) -> Void
    
    init(
        _ mod: MinecraftInstalledProject,
        canUpdate: @escaping (MinecraftInstalledProject) -> Bool,
        installModUpdate: @escaping (MinecraftInstalledProject) -> Void
    ) {
        self.mod = mod
        self.canUpdate = canUpdate
        self.installModUpdate = installModUpdate
    }
    
    var body: some View {
        HStack(spacing: 10) {
            MinecraftCatalogIcon(
                mod.iconURL,
                placeholderSystemImage: "shippingbox.fill",
                size: 44,
                cornerRadius: 8
            )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(mod.projectName ?? mod.path)
                    .subheadline()
                    .lineLimit(2)
                
                InstalledMinecraftProjectMetadataView(
                    version: mod.installedVersionDisplayName,
                    provider: ModManagerProvider(providerValue: mod.provider)?.name ?? mod.providerDisplayName
                )
            }
            
            Spacer()
            
            if canUpdate(mod) {
                Button("Update", systemImage: "square.and.arrow.down") {
                    installModUpdate(mod)
                }
                .semibold()
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .labelStyle(.iconOnly)
                .disabled(vm.isInstallingMod)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .backgroundStyling(store.panelSidebarBackgroundStyle, in: .rect(cornerRadius: 16))
    }
}

//#Preview {
//    InstalledModCard()
//}
