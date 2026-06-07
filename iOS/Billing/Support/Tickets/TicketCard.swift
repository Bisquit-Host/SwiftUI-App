import SwiftUI
import BisquitoNet

struct TicketCard: View {
    let ticket: SupportTicketWithLastMessageDTO
    let vm: TicketListVM
    @State private var alertCloseTicket = false
    
    init(_ ticket: SupportTicketWithLastMessageDTO, vm: TicketListVM) {
        self.ticket = ticket
        self.vm = vm
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
        .contextMenu {
            if ticket.ticket.status != .closed {
                Button("Close Ticket", systemImage: "xmark", role: .destructive) {
                    alertCloseTicket = true
                }
                .disabled(vm.isClosingTicket(ticket.ticket))
            }
        }
        .alert("Close this ticket?", isPresented: $alertCloseTicket) {
            Button("Close Ticket", role: .destructive) {
                Task {
                    _ = await vm.closeTicket(ticket.ticket)
                }
            }
        } message: {
            Text("You will not be able to send more messages in this ticket")
        }
    }
}
