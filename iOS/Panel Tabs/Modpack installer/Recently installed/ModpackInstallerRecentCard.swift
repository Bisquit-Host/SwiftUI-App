import SwiftUI

struct ModpackInstallerRecentCard: View {
    private let modpack: InstalledModpack
    
    init(_ modpack: InstalledModpack) {
        self.modpack = modpack
    }
    
    var body: some View {
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

//#Preview {
//    ModpackInstallerRecentCard()
//}
