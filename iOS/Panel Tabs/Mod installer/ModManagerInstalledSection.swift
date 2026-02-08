import SwiftUI

struct ModManagerInstalledSection: View {
    @Environment(ModInstallerVM.self) private var vm
    
    let canUpdate: (MinecraftInstalledProject) -> Bool
    let installModUpdate: (MinecraftInstalledProject) -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                BillingSectionCard("Installed mods") {
                    if vm.installedMinecraftMods.isEmpty {
                        Text("No installed mods")
                            .secondary()
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(vm.installedMinecraftMods) { mod in
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
                                        .disabled(vm.isInstallingMinecraftMod)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .scrollIndicators(.never)
        .frame(maxWidth: .infinity)
        .background(BackgroundImage())
    }
}

#Preview {
    ModManagerInstalledSection(
        canUpdate: { _ in true },
        installModUpdate: { _ in }
    )
    .darkSchemePreferred()
    .environment(ModInstallerVM(""))
}
