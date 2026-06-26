import SwiftUI

struct InstalledPluginList: View {
    @Environment(PluginInstallerVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    let canUpdate: (MinecraftInstalledProject) -> Bool
    let installPluginUpdate: (MinecraftInstalledProject) -> Void
    
    var body: some View {
        ScrollView {
            BillingSectionCard(showsBackground: false) {
                if vm.installedPlugins.isEmpty {
                    Text("No installed plugins")
                        .secondary()
                } else {
                    VStack(alignment: .leading) {
                        ForEach(vm.installedPlugins) {
                            InstalledPluginCard(plugin: $0, canUpdate: canUpdate, installPluginUpdate: installPluginUpdate)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .backgroundStyling(store.panelSidebarBackgroundStyle, in: .rect(cornerRadius: 16))
        }
        .padding()
        .scrollIndicators(.never)
        .frame(maxWidth: .infinity)
        .background(BackgroundImage())
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
