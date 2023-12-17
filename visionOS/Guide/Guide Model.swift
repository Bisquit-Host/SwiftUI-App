import Foundation

struct GuideStep {
    let text: LocalizedStringResource
    let id: Int
    let url: URL
    
    init(_ text: LocalizedStringResource,
         id: Int,
         url: URL
    ) {
        self.text = text
        self.id = id
        self.url = url
    }
}
