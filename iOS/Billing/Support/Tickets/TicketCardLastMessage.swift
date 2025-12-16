import SwiftUI

struct TicketCardLastMessage: View {
    private let ticket: SupportTicketWithLastMessageDTO
    
    init(_ ticket: SupportTicketWithLastMessageDTO) {
        self.ticket = ticket
    }
    
    var body: some View {
        if let last = ticket.lastMessage {
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
