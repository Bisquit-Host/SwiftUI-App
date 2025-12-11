import SwiftUI

struct SupportTicketsList: View {
    @State private var vm = SupportTicketsVM()
    
    @State private var showCreateSheet = false
    @State private var alertTooManyTickets = false
    
    var body: some View {
        List {
            Section {
                Toggle("Show closed", isOn: $vm.showClosed)
            }
            
            Section("Tickets") {
                if vm.isLoading && vm.tickets.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color.clear)
                    
                } else if vm.tickets.isEmpty {
                    ContentUnavailableView("No tickets yet", systemImage: "text.bubble")
                        .listRowBackground(Color.clear)
                    
                } else {
                    ForEach(vm.tickets) { item in
                        NavigationLink {
                            SupportTicketDetails(item.ticket)
                        } label: {
                            SupportTicketCard(item)
                        }
                    }
                }
            }
        }
        .navigationTitle("Support")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("New", systemImage: "plus") {
                    createNewTicket()
                }
            }
        }
        .sheet($showCreateSheet) {
            NavigationStack {
                CreateTicketSheet(showSheet: $showCreateSheet)
                    .environment(vm)
            }
        }
        .refreshableTask {
            await vm.loadTickets()
        }
        .onChange(of: vm.showClosed) { _, _ in
            Task {
                await vm.loadTickets()
            }
        }
        .alert("Too many open tickets", isPresented: $alertTooManyTickets) {
            Button("Okay") {}
        } message: {
            Text("You already have 2 open tickets")
        }
    }
    
    private func createNewTicket() {
        let totalCount = vm.tickets.filter {
            $0.ticket.status == .open || $0.ticket.status == .pending
        }.count
        
        if totalCount >= 2 {
            alertTooManyTickets = true
        } else {
            showCreateSheet = true
        }
    }
}

#Preview {
    NavigationStack {
        SupportTicketsList()
    }
    .environment(SupportTicketsVM())
    .environmentObject(ValueStore())
    .darkSchemePreferred()
}
