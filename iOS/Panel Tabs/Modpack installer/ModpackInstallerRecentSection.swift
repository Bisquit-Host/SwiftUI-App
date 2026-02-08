import SwiftUI

struct ModpackInstallerRecentSection: View {
    let modpacks: [InstalledModpack]
    
    var body: some View {
        BillingSectionCard("Most recently installed modpacks") {
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
    }
}
