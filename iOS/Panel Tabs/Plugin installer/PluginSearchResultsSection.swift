import SwiftUI

struct PluginSearchResultsSection: View {
    let pluginManagerAvailable: Bool
    let plugins: [MinecraftCatalogProject]
    let pagination: MinecraftPagination
    let isLoadingPlugins: Bool
    
    @Binding var selectedPlugin: MinecraftCatalogProject?
    
    let movePage: (Int) -> Void
    
    var body: some View {
        if !pluginManagerAvailable {
            Text("Plugin manager is unavailable")
                .secondary()
            
        } else if plugins.isEmpty {
            Text("No plugins found")
                .secondary()
            
        } else {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(plugins) { plugin in
                    Button {
                        selectedPlugin = plugin
                    } label: {
                        PluginSearchResultCard(plugin)
                    }
                    .buttonStyle(.plain)
                    .minecraftProjectContextMenu(webPageURL: plugin.webPageURL)
                }
                
                if pagination.totalPages > 1 {
                    MinecraftToolsPaginationView(
                        currentPage: pagination.currentPage,
                        totalPages: pagination.totalPages,
                        isLoading: isLoadingPlugins,
                        onPrevious: { movePage(-1) },
                        onNext: { movePage(1) }
                    )
                }
            }
        }
    }
}
