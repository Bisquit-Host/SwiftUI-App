import SwiftUI
import BisquitoNet

struct TicketCardLastMessage: View {
    private let lastMessage: SupportMessageDTO?
    
    init(_ lastMessage: SupportMessageDTO?) {
        self.lastMessage = lastMessage
    }
    
    var body: some View {
        if let last = lastMessage {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(last.user.isSupport ? "Support" : last.user.name)
                    .caption(.semibold)
                    .secondary()
                
                let text = last.message ?? ""
                
                Text(text.isEmpty ? "Attachment" : text)
                    .subheadline()
                    .lineLimit(1)
                    .foregroundStyle(.primary)
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
