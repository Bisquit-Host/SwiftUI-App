import Foundation
import Calagopus

struct AgentChatMessage: Identifiable, Hashable {
    let id: String
    let order: Int
    let role: String
    let images: [AgentChatMessageImage]
    var content: String
    var targetContent: String
    
    var isUser: Bool {
        role == "user"
    }
    
    var isFullyRevealed: Bool {
        content == targetContent
    }
    
    var markdownContent: AttributedString {
        (
            try? AttributedString(
                markdown: content,
                options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .full)
            )
        ) ?? AttributedString(content)
    }
    
    init?(_ json: CalagopusJSON) {
        guard let object = json.objectValue else { return nil }
        
        let parsedOrder = object["order"]?.intValue ?? 0
        let parsedRole = object["role"]?.stringValue ?? "assistant"
        let parsedContent = object["content"]?.stringValue ?? ""
        
        id = object["id"]?.stringValue ?? "\(parsedRole)-\(parsedOrder)"
        order = parsedOrder
        role = parsedRole
        images = object["images"]?.arrayValue?.compactMap(AgentChatMessageImage.init) ?? []
        content = parsedContent
        targetContent = parsedContent
    }
}
