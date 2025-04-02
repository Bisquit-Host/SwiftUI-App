import SwiftUI

struct Card: Identifiable, Hashable {
    var id = UUID()
    let image: ImageResource
    
    init(_ image: ImageResource) {
        self.image = image
    }
}

let cards = [
    Card(.intro1),
    Card(.intro2),
    Card(.intro3)
]
