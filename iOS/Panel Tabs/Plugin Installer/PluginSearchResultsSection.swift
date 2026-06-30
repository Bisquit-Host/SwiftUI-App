import SwiftUI
import Calagopus

struct PluginSearchResultsSection: View {
    @Environment(PluginInstallerVM.self) private var vm
    
    @Binding var selectedPlugin: MinecraftCatalogProject?
    let movePage: (Int) -> Void
    
    var body: some View {
        if !vm.pluginManagerAvailable {
            Text("Plugins are unavailable")
                .secondary()
            
        } else if vm.plugins.isEmpty && !vm.isLoadingPlugins {
            Text("No plugins found")
                .secondary()
            
        } else {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(vm.plugins) { plugin in
                    Button {
                        selectedPlugin = plugin
                    } label: {
                        PluginSearchResultCard(plugin)
                    }
                    .buttonStyle(.plain)
                    .minecraftProjectContextMenu(webPageURL: plugin.webPageURL)
                }
                
                if vm.pluginsPagination.totalPages > 1 {
                    MinecraftToolsPagination(
                        currentPage: vm.pluginsPagination.currentPage,
                        totalPages: vm.pluginsPagination.totalPages,
                        isLoading: vm.isLoadingPlugins,
                        onPrevious: { movePage(-1) },
                        onNext: { movePage(1) }
                    )
                }
            }
        }
    }
}
