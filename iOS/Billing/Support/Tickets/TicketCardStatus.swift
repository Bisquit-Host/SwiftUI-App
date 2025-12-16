import SwiftUI

struct TicketCardStatus: View {
    private let ticket: SupportTicketWithLastMessageDTO
    
    init(_ ticket: SupportTicketWithLastMessageDTO) {
        self.ticket = ticket
    }
    
    var body: some View {
        Text(ticket.ticket.status.rawValue.capitalized)
            .caption(.semibold)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(ticket.ticket.status.color.opacity(0.12), in: Capsule())
            .foregroundStyle(ticket.ticket.status.color)
    }
}

//#Preview {
//    TicketCardStatus()
//        .darkSchemePreferred()
//}
