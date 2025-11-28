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
                            SupportTicketDetailView(ticket: item.ticket)
                        } label: {
                            SupportTicketRow(item)
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
                SupportTicketCreateView(vm: vm, showSheet: $showCreateSheet)
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

private struct SupportTicketRow: View {
    let ticket: SupportTicketWithLastMessageDTO
    
    init(_ ticket: SupportTicketWithLastMessageDTO) {
        self.ticket = ticket
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(ticket.ticket.title)
                    .headline()
                    .lineLimit(2)
                
                Spacer()
                
                Text(ticket.ticket.status.capitalized)
                    .caption(.semibold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.12), in: Capsule())
                    .foregroundStyle(statusColor)
            }
            
            if let last = ticket.lastMessage {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(last.user.isSupport ? "Support" : last.user.name)
                        .caption(.semibold)
                        .secondary()
                    
                    Text(last.message.isEmpty ? "Attachment" : last.message)
                        .subheadline()
                        .lineLimit(1)
                        .foregroundStyle(.primary)
                }
            } else {
                Text("No messages yet")
                    .subheadline()
                    .secondary()
            }
        }
        .padding(.vertical, 4)
    }
    
    private var statusColor: Color {
        switch ticket.ticket.status.lowercased() {
        case "open": .green
        case "pending": .orange
        default: .gray
        }
    }
}

private struct SupportTicketCreateView: View {
    @Bindable var vm: SupportTicketsVM
    @Binding var showSheet: Bool
    @EnvironmentObject private var store: ValueStore
    
    @State private var title = ""
    @State private var message = ""
    
    var body: some View {
        Form {
            Section("Title") {
                TextField("Brief summary", text: $title)
            }
            
            Section("Message") {
                TextEditor(text: $message)
                    .frame(minHeight: 160)
            }
        }
        .navigationTitle("New Ticket")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") {
                    showSheet = false
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Submit") {
                    Task {
                        if let id = await vm.createTicket(accessToken: store.testAccessToken, title: title, message: message) {
                            showSheet = false
                            await vm.loadTickets(accessToken: store.testAccessToken)
                        }
                    }
                }
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                          message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
