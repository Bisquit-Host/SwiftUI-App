import SwiftUI
import Calagopus

struct InstalledPluginList: View {
    @Environment(PluginInstallerVM.self) private var vm
    
    let canUpdate: (MinecraftInstalledProject) -> Bool
    let installPluginUpdate: (MinecraftInstalledProject) -> Void
    
    var body: some View {
        ScrollView {
            if !vm.installedPlugins.isEmpty {
                ForEach(vm.installedPlugins) {
                    InstalledPluginCard(plugin: $0, canUpdate: canUpdate, installPluginUpdate: installPluginUpdate)
                }
            }
        }
        .navigationTitle("Installed Plugins")
        .toolbarTitleDisplayMode(.inline)
        .scenePadding(.horizontal)
        .scrollIndicators(.never)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BackgroundImage())
        .overlay {
            if vm.installedPlugins.isEmpty {
                ContentUnavailableView(
                    "No installed plugins",
                    systemImage: "puzzlepiece.fill",
                    description: Text("Installed plugins will appear here")
                )
            }
        }
    }
}

#Preview {
    InstalledPluginList(
        canUpdate: { _ in true },
        installPluginUpdate: { _ in }
    )
    .darkSchemePreferred()
    .environment(PluginInstallerVM(""))
    .environmentObject(ValueStore())
}
