import SwiftUI
import Calagopus

struct InstalledPluginList: View {
    @Environment(PluginInstallerVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    let canUpdate: (MinecraftInstalledProject) -> Bool
    let installPluginUpdate: (MinecraftInstalledProject) -> Void
    
    var body: some View {
        ScrollView {
            if !vm.installedPlugins.isEmpty {
                BillingSectionCard(showsBackground: false) {
                    VStack(alignment: .leading) {
                        ForEach(vm.installedPlugins) {
                            InstalledPluginCard(plugin: $0, canUpdate: canUpdate, installPluginUpdate: installPluginUpdate)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .backgroundStyling(store.panelSidebarBackgroundStyle, in: .rect(cornerRadius: 16))
            }
        }
        .padding()
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
