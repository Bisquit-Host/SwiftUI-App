import SwiftUI

struct ModpackInstallerResultCard: View {
    @EnvironmentObject private var store: ValueStore
    
    private let modpack: MinecraftCatalogProject
    
    init(_ modpack: MinecraftCatalogProject) {
        self.modpack = modpack
    }
    
    var body: some View {
        HStack(spacing: 12) {
            MinecraftCatalogIcon(
                modpack.iconURL,
                placeholderSystemImage: "square.stack.3d.up.fill",
                size: 28,
                cornerRadius: 8
            )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(modpack.name)
                    .subheadline(.semibold)
                    .foregroundStyle(.foreground)
                
                if !modpack.description.isEmpty {
                    Text(modpack.description)
                        .caption()
                        .secondary()
                        .lineLimit(2)
                }

                MinecraftCatalogProjectStatsView(modpack)
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
    ModpackInstallerResultCard(
        MinecraftCatalogProject(
            id: "modpack-preview",
            name: "Example Modpack",
            description: "Example description for preview",
            url: nil,
            iconURLString: nil,
            externalURL: nil
        )
    )
    .padding()
    .environmentObject(ValueStore())
}
