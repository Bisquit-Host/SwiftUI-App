import SwiftUI

struct SupportTicketsList: View {
    @EnvironmentObject private var store: ValueStore
    @State private var vm = SupportTicketsVM()
    @State private var showCreateSheet = false
    
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
                    showCreateSheet = true
                }
            }
        }
        .sheet($showCreateSheet) {
            NavigationStack {
                CreateTicketSheet(vm: vm, showSheet: $showCreateSheet)
            }
        }
        .refreshableTask {
            await vm.loadTickets(accessToken: store.testAccessToken)
        }
        .onChange(of: vm.showClosed) { _, _ in
            Task {
                await vm.loadTickets(accessToken: store.testAccessToken)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SupportTicketsList()
    }
    .environmentObject(ValueStore())
    .darkSchemePreferred()
}
