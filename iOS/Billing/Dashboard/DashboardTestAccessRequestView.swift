import SwiftUI

struct DashboardTestAccessRequestView: View {
    @State private var ticketVM = TicketListVM()
    @State private var showsRequestGuidance = false
    
    var body: some View {
        @Bindable var ticketVM = ticketVM
        
        GlassyActionCard("Request test access", icon: "testtube.2", tint: .blue) {
            showsRequestGuidance = true
        }
        .alert("Request test access", isPresented: $showsRequestGuidance) {
            Button("Cancel", role: .cancel) {}
            Button("Continue") {
                requestTestAccess()
            }
        } message: {
            Text("In the message, mention which plan you want to test and which location")
        }
        .alert("Too many open tickets", isPresented: $ticketVM.alertTooManyTickets) {
            Button("Okay") {}
        } message: {
            Text("You already have 2 open tickets")
        }
        .sheet($ticketVM.showCreateSheet) {
            NavigationStack {
                CreateTicketSheet(
                    navigationTitle: "Request test access",
                    title: "Request test access",
                    isTitleEditable: false,
                    showsTitleSection: false,
                    areAttachmentsOptional: true
                )
                .environment(ticketVM)
            }
        }
    }
    
    private func requestTestAccess() {
        Task {
            await ticketVM.fetchTickets()
            ticketVM.createNewTicket()
        }
    }
}

#Preview {
    DashboardTestAccessRequestView()
        .padding()
        .darkSchemePreferred()
}
