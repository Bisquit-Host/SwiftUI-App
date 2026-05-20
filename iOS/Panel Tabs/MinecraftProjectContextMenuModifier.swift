import SwiftUI
import SafariCover

struct MinecraftProjectContextMenuModifier: ViewModifier {
    @State private var showSafari = false
    
    let webPageURL: String?
    
    func body(content: Content) -> some View {
        content.contextMenu {
            if let webPageURL {
                if URL(string: webPageURL) != nil {
                    Button("Open in browser", systemImage: "safari") {
                        showSafari = true
                    }
                }
                
                ShareLink(item: webPageURL)
            }
        }
        .safariCover($showSafari, url: webPageURL ?? "")
    }
}

extension View {
    func minecraftProjectContextMenu(webPageURL: String?) -> some View {
        modifier(MinecraftProjectContextMenuModifier(webPageURL: webPageURL))
    }
}
