import ScrechKit
import SafariCover

struct DiscoverCard: View {
    private let link: DiscoverItem
    
    init(_ link: DiscoverItem) {
        self.link = link
    }
    
    @State private var showSafari = false
    
    var body: some View {
        ListButton(
            LocalizedStringResource(stringLiteral: link.name),
            icon: link.icon,
            actionIcon: "link",
            color: link.color
        ) {
            showSafari = true
        }
        .safariCover($showSafari, url: link.url)
    }
}
