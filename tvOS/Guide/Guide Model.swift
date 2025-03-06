import SwiftUI

struct GuideStep: Identifiable {
    let text: LocalizedStringResource
    let id: Int
    let image: ImageResource
    
    init(_ text: LocalizedStringResource, id: Int, image: ImageResource) {
        self.text = text
        self.id = id
        self.image = image
    }
}
