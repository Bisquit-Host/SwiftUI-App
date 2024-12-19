import SwiftData

@Model
final class APIKey {
    var name = ""
    
    @Attribute(.allowsCloudEncryption)
    var key = generateRandomKeyNumber()
    
    init(_ name: String = "", key: String = generateRandomKeyNumber()) {
        self.name = name
        self.key = key
    }
}

func generateRandomKeyNumber() -> String {
    let id = String(Int.random(in: 100...999))
    
    return "API-key #" + id
}
