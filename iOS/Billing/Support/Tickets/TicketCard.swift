import SwiftUI
import BisquitoNet

struct TicketCard: View {
    let ticket: SupportTicketWithLastMessageDTO
    
    init(_ ticket: SupportTicketWithLastMessageDTO) {
        self.ticket = ticket
    }
    
    var body: some View {
        NavigationLink {
            TicketDetails(ticket.ticket)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(ticket.ticket.title)
                        .headline()
                        .lineLimit(2)
                    
                    TicketCardLastMessage(ticket.lastMessage)
                }
                
                Spacer()
                
                TicketCardStatus(ticket.ticket.status)
            }
            .padding(.vertical, 4)
        }
    }
}
