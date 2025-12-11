import SwiftUI

struct TicketList: View {
    @Environment(TicketListVM.self) private var vm
    
    var body: some View {
        @Bindable var vm = vm
        
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
                            TicketDetails(item.ticket)
                        } label: {
                            TicketCard(item)
                        }
                    }
                }
            }
        }
        .refreshableTask {
            await vm.fetchTickets()
        }
        .onChange(of: vm.showClosed) { _, _ in
            Task {
                await vm.fetchTickets()
            }
        }
        .alert("Too many open tickets", isPresented: $vm.alertTooManyTickets) {
            Button("Okay") {}
        } message: {
            Text("You already have 2 open tickets")
        }
        .sheet($vm.showCreateSheet) {
            NavigationStack {
                CreateTicketSheet()
                    .environment(vm)
            }
        }
    }
}

#Preview {
    NavigationStack {
        List {
            TicketList()
        }
    }
    .environment(TicketListVM())
    .environmentObject(ValueStore())
    .darkSchemePreferred()
}
