import SwiftUI

struct SupportTicketDetailView: View {
    @EnvironmentObject private var store: ValueStore
    @State private var vm: SupportTicketDetailVM
    
    init(ticket: SupportTicketDTO) {
        _vm = State(initialValue: SupportTicketDetailVM(ticket: ticket))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            List {
                Section {
                    HStack {
                        Text(vm.ticket.title)
                            .headline()
                        
                        Spacer()
                        
                        Text(vm.ticket.status.capitalized)
                            .caption(.semibold)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(statusColor.opacity(0.12), in: Capsule())
                            .foregroundStyle(statusColor)
                    }
                }
                
                Section("Conversation") {
                    if vm.messages.isEmpty {
                        ContentUnavailableView("No messages yet", systemImage: "ellipsis.bubble")
                    } else {
                        ForEach(vm.messages) { message in
                            SupportMessageRow(message: message, isCurrentUser: message.userId == vm.ticket.userId)
                                .listRowSeparator(.hidden)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            
            Divider()
            
            HStack(alignment: .bottom, spacing: 12) {
                TextEditor(text: $vm.composerText)
                    .frame(minHeight: 46, maxHeight: 120)
                    .padding(8)
                    .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))
                
                Button {
                    Task {
                        await vm.sendMessage(accessToken: store.testAccessToken)
                    }
                } label: {
                    Image(systemName: vm.isSending ? "paperplane.fill" : "paperplane")
                        .font(.title3)
                        .padding(10)
                }
                .disabled(vm.composerText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || vm.isSending)
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(.thinMaterial)
        }
        .navigationTitle("Ticket #\(vm.ticket.id)")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            vm.start(accessToken: store.testAccessToken)
        }
        .onDisappear {
            vm.stop()
        }
    }
    
    private var statusColor: Color {
        switch vm.ticket.status.lowercased() {
        case "open": .green
        case "pending": .orange
        default: .gray
        }
    }
}

private struct SupportMessageRow: View {
    let message: SupportMessageDTO
    let isCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isCurrentUser {
                Spacer(minLength: 40)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(message.user.isSupport ? "Support" : message.user.name)
                        .caption(.semibold)
                        .secondary()
                    
                    Spacer()
                    
                    Text(message.createdAt)
                        .caption2()
                        .secondary()
                }
                
                if !message.message.isEmpty {
                    Text(message.message)
                        .padding(10)
                        .background(isCurrentUser ? Color.accentColor.opacity(0.15) : Color.secondary.opacity(0.08), in: .rect(cornerRadius: 12))
                }
                
                if let media = message.media, !media.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(media, id: \.self) { item in
                            Label(item, systemImage: "paperclip")
                                .caption()
                                .lineLimit(2)
                                .padding(8)
                                .background(.secondary.opacity(0.08), in: .rect(cornerRadius: 10))
                        }
                    }
                }
            }
            
            if !isCurrentUser {
                Spacer(minLength: 40)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SupportTicketDetailView(ticket: .init(id: 1, title: "Example issue", status: "open", userId: 1, createdAt: "2024-01-01T10:00:00Z", updatedAt: "2024-01-01T10:00:00Z"))
    }
    .environmentObject(ValueStore())
    .darkSchemePreferred()
}
