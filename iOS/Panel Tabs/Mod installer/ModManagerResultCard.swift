import SwiftUI

struct ModManagerResultCard: View {
    @EnvironmentObject private var store: ValueStore
    
    private let mod: MinecraftCatalogProject
    
    init(_ mod: MinecraftCatalogProject) {
        self.mod = mod
    }
    
    var body: some View {
        HStack(spacing: 12) {
            MinecraftCatalogIcon(
                mod.iconURL,
                placeholderSystemImage: "shippingbox.fill",
                size: 28,
                cornerRadius: 8
            )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(mod.name)
                    .subheadline(.semibold)
                    .foregroundStyle(.foreground)
                
                Text(mod.description)
                    .caption()
                    .secondary()
                    .lineLimit(2)
                
                MinecraftCatalogProjectStatsView(project: mod)
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
    ModManagerResultCard(
        MinecraftCatalogProject(
            id: "mod-preview",
            name: "Example Mod",
            description: "Example description for preview",
            url: nil,
            iconURLString: nil,
            externalURL: nil
        )
    )
    .padding()
    .environmentObject(ValueStore())
}
