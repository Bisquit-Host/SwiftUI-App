import SwiftUI

struct TicketList: View {
    @Environment(TicketListVM.self) private var vm
    
    var body: some View {
        @Bindable var vm = vm
        
        List {
            Section {
                Toggle("Show closed tickets", isOn: $vm.showClosed)
            }
            
            Section {
                if vm.isLoading && vm.tickets.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color.clear)
                    
                } else if vm.tickets.isEmpty {
                    ContentUnavailableView("No tickets yet", systemImage: "text.bubble")
                        .listRowBackground(Color.clear)
                    
                } else {
                    ForEach(vm.tickets) {
                        TicketCard($0, vm: vm)
                    }
                }
            } header: {
                if !vm.tickets.isEmpty {
                    Text("Tickets")
                }
            }
        }
        .navigationTitle("Support")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("New", systemImage: "plus", action: vm.createNewTicket)
            }
        }
        .refreshableTask {
            await vm.fetchTickets()
        }
        .task {
            for await _ in NotificationCenter.default.notifications(named: UIApplication.didBecomeActiveNotification) {
                await vm.fetchTickets()
            }
        }
        .onChange(of: vm.showClosed) {
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
