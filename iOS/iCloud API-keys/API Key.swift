import SwiftData

@Model
final class APIKey {
    var name = ""
    
    @Attribute(.allowsCloudEncryption)
    var key = ""
    
    init(_ name: String, key: String) {
        self.name = name
        self.key = key
    }
}
