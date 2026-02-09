import SwiftUI

struct PluginSearchResultCard: View {
    @EnvironmentObject private var store: ValueStore
    
    private let plugin: MinecraftCatalogProject
    
    init(_ plugin: MinecraftCatalogProject) {
        self.plugin = plugin
    }
    
    var body: some View {
        HStack(spacing: 12) {
            MinecraftCatalogIcon(
                plugin.iconURL,
                placeholderSystemImage: "puzzlepiece.fill",
                size: 28,
                cornerRadius: 8
            )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(plugin.name)
                    .subheadline(.semibold)
                    .foregroundStyle(.foreground)
                
                Text(plugin.description)
                    .caption()
                    .secondary()
                    .lineLimit(2)
                
                MinecraftCatalogProjectStatsView(project: plugin)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .secondary()
                .footnote()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .backgroundStyling(store.panelSidebarBackgroundStyle, in: .rect(cornerRadius: 12))
        .contentShape(.rect)
    }
}

#Preview {
    PluginSearchResultCard(
        MinecraftCatalogProject(
            id: "plugin-preview",
            name: "Example Plugin",
            description: "Example description for preview",
            url: nil,
            iconURLString: nil,
            externalURL: nil
        )
    )
    .padding()
    .environmentObject(ValueStore())
}
