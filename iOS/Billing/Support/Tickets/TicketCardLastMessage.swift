import ScrechKit
import BisquitoNet

struct TicketCardLastMessage: View {
    private let lastMessage: SupportMessageDTO?
    
    init(_ lastMessage: SupportMessageDTO?) {
        self.lastMessage = lastMessage
    }
    
    var body: some View {
        if let last = lastMessage {
            VStack(alignment: .leading, spacing: 2) {
                Text(last.user.isSupport ? "Support" : last.user.name)
                    .caption(.semibold)
                    .secondary()
                
                let text = last.message ?? ""
                
                Text(text.isEmpty ? "Attachment" : text)
                    .subheadline()
                    .lineLimit(1)
                    .foregroundStyle(.primary)
                
                Text(timeSinceISO(last.createdAt))
                    .caption2()
                    .secondary()
            }
        } else {
            Text("No messages yet")
                .subheadline()
                .secondary()
        }
    }
}

//#Preview {
//    TicketCardLastMessage()
//        .darkSchemePreferred()
//}
