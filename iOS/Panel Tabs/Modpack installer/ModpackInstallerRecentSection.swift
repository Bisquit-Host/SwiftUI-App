import SwiftUI

struct ModpackInstallerRecentSection: View {
    @EnvironmentObject private var store: ValueStore
    
    private let modpacks: [InstalledModpack]
    
    init(_ modpacks: [InstalledModpack]) {
        self.modpacks = modpacks
    }
    
    var body: some View {
        BillingSectionCard("Most recently installed modpacks", showsBackground: false) {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(modpacks) { modpack in
                    HStack(alignment: .top, spacing: 10) {
                        MinecraftCatalogIcon(
                            modpack.iconURL,
                            placeholderSystemImage: "square.stack.3d.up.fill",
                            size: 28,
                            cornerRadius: 8
                        )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(modpack.name)
                                .subheadline(.semibold)
                            
                            if !modpack.description.isEmpty {
                                Text(modpack.description)
                                    .caption()
                                    .secondary()
                                    .lineLimit(2)
                            }
                            
                            Text(modpack.provider)
                                .caption()
                                .secondary()
                        }
                    }
                    .minecraftProjectContextMenu(webPageURL: modpack.webPageURL)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .backgroundStyling(store.panelSidebarBackgroundStyle, in: .rect(cornerRadius: 16))
    }
}
