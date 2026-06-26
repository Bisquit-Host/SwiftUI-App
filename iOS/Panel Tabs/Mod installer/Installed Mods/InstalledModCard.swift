import SwiftUI
import Calagopus

struct InstalledModCard: View {
    @Environment(ModInstallerVM.self) private var vm
    
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
                size: 22,
                cornerRadius: 6
            )
            
            Text(mod.projectName ?? mod.path)
                .subheadline()
                .lineLimit(2)
            
            Spacer()
            
            if canUpdate(mod) {
                Button("Update") {
                    installModUpdate(mod)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .tint(.yellow)
                .disabled(vm.isInstallingMod)
            }
        }
    }
}

//#Preview {
//    InstalledModCard()
//}
