import SwiftUI
import BisquitoNet

struct TicketCard: View {
    @Environment(TicketListVM.self) private var vm
    @State private var alertCloseTicket = false
    @State private var showsTicketDetails = false

    let ticket: SupportTicketWithLastMessageDTO

    init(_ ticket: SupportTicketWithLastMessageDTO) {
        self.ticket = ticket
    }
    
    var body: some View {
        Button {
            showsTicketDetails = true
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(ticket.ticket.title)
                        .headline()
                        .lineLimit(2)

                    Spacer()

                    TicketCardStatus(ticket.ticket.status)
                }

                TicketCardLastMessage(ticket.lastMessage)
            }
            .padding()
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .listRowInsets(.init(top: 6, leading: 0, bottom: 6, trailing: 0))
        .navigationDestination(isPresented: $showsTicketDetails) {
            TicketDetails(ticket.ticket)
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
