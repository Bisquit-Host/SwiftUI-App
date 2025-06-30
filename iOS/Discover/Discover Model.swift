import SwiftUI

struct DiscoverModel: Identifiable {
    let id = UUID()
    
    let title, subtitle: LocalizedStringKey
    let image: ImageResource
    
    init(
        _ title: LocalizedStringKey,
        subtitle: LocalizedStringKey,
        image: ImageResource
    ) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
    }
}
