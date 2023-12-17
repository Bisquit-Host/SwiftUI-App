import Foundation

struct IntroItem {
    let title: LocalizedStringResource
    let text: LocalizedStringResource
    let imageName: String
    
    init(_ title: LocalizedStringResource,
         text: LocalizedStringResource,
         imageName: String
    ) {
        self.title = title
        self.text = text
        self.imageName = imageName
    }
}
