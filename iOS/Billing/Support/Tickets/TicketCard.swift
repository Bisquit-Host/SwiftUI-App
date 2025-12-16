import SwiftUI

struct TicketCard: View {
    let ticket: SupportTicketWithLastMessageDTO
    
    init(_ ticket: SupportTicketWithLastMessageDTO) {
        self.ticket = ticket
    }
    
    var body: some View {
        NavigationLink {
            TicketDetails(ticket.ticket)
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(ticket.ticket.title)
                        .headline()
                        .lineLimit(2)
                    
                    Spacer()
                    
                    Text(ticket.ticket.status.rawValue.capitalized)
                        .caption(.semibold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(ticket.ticket.status.color.opacity(0.12), in: Capsule())
                        .foregroundStyle(ticket.ticket.status.color)
                }
                
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
            .padding(.vertical, 4)
        }
    }
}
