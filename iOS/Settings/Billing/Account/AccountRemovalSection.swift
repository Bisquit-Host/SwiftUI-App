import SwiftUI

struct AccountRemovalSection: View {
    @State private var ticketVM = TicketListVM()
    
    var body: some View {
        @Bindable var ticketVM = ticketVM
        
        BillingSectionCard("Danger zone") {
            GlassyActionCard("Request account removal", icon: "person.crop.circle.badge.minus", tint: .red, role: .destructive) {
                requestAccountRemoval()
            }
        }
        .alert("Too many open tickets", isPresented: $ticketVM.alertTooManyTickets) {
            Button("Okay") {}
        } message: {
            Text("You already have 2 open tickets")
        }
        .sheet($ticketVM.showCreateSheet) {
            NavigationStack {
                CreateTicketSheet(.accountRemoval)
                    .environment(ticketVM)
            }
        }
    }
    
    private func requestAccountRemoval() {
        Task {
            await ticketVM.fetchTickets()
            ticketVM.createNewTicket()
        }
    }
}
