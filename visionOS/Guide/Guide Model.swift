import Foundation

struct GuideStep: Identifiable {
    let text: LocalizedStringResource
    let id: Int
    let url: URL
    
    init(_ text: LocalizedStringResource, id: Int, url: URL) {
        self.text = text
        self.id = id
        self.url = url
    }
}
