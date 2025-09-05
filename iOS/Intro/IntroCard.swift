import SwiftUI

struct IntroCard: Identifiable, Hashable {
    var id = UUID()
    let image: ImageResource
    
    init(_ image: ImageResource) {
        self.image = image
    }
}
