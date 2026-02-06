import SwiftUI

struct MinecraftPluginInstalledTab: View {
    @Environment(StartupVM.self) private var vm
    
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
                                    AsyncImage(url: plugin.iconURL) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        Image(systemName: "puzzlepiece.fill")
                                            .secondary()
                                    }
                                    .frame(width: 22, height: 22)
                                    .clipShape(.rect(cornerRadius: 6))
                                    
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
    }
}

#Preview {
    MinecraftPluginInstalledTab(
        canUpdate: { _ in true },
        installPluginUpdate: { _ in }
    )
    .darkSchemePreferred()
    .environment(StartupVM(""))
}
