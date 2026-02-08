import SwiftUI
import SafariCover

struct MinecraftProjectContextMenuModifier: ViewModifier {
    @State private var showSafari = false
    
    let webPageURL: String?
    
    func body(content: Content) -> some View {
        content.contextMenu {
            if let webPageURL {
                if URL(string: webPageURL) != nil {
                    Button {
                        showSafari = true
                    } label: {
                        Label("Open page", systemImage: "safari")
                    }
                }
                
                ShareLink(item: webPageURL) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
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
