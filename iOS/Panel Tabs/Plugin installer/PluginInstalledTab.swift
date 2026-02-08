import SwiftUI

struct PluginInstalledTab: View {
    @Environment(PluginInstallerVM.self) private var vm
    
    let canUpdate: (MinecraftInstalledProject) -> Bool
    let installPluginUpdate: (MinecraftInstalledProject) -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                BillingSectionCard("Installed plugins") {
                    if vm.installedMinecraftPlugins.isEmpty {
                        Text("No installed plugins")
                            .secondary()
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(vm.installedMinecraftPlugins) { plugin in
                                HStack(spacing: 10) {
                                    MinecraftCatalogIcon(
                                        plugin.iconURL,
                                        placeholderSystemImage: "puzzlepiece.fill",
                                        size: 22,
                                        cornerRadius: 6
                                    )
                                    
                                    Text(plugin.fileName)
                                        .subheadline()
                                        .lineLimit(2)
                                    
                                    Spacer()
                                    
                                    if canUpdate(plugin) {
                                        Button("Update") {
                                            installPluginUpdate(plugin)
                                        }
                                        .buttonStyle(.borderedProminent)
                                        .controlSize(.small)
                                        .tint(.yellow)
                                        .disabled(vm.isInstallingMinecraftPlugin)
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
        .background(BackgroundImage())
    }
}

#Preview {
    PluginInstalledTab(
        canUpdate: { _ in true },
        installPluginUpdate: { _ in }
    )
    .darkSchemePreferred()
    .environment(PluginInstallerVM(""))
}
