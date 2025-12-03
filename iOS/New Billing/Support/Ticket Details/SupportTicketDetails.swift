import SwiftUI

struct SupportTicketDetails: View {
    @State private var vm: SupportTicketDetailsVM
    @EnvironmentObject private var store: ValueStore
    init(_ ticket: SupportTicketDTO) {
        _vm = State(initialValue: SupportTicketDetailsVM(ticket))
    }
    
    @State private var selectedMedia: String? = nil
    @State private var attachments: [PendingAttachment] = []
    
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
                            TicketMessageRow(message: message, isCurrentUser: message.userId == vm.ticket.userId) { path in
                                selectedMedia = path
                            }
                            .listRowSeparator(.hidden)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            
            Divider()
            
            SupportMessageComposer(text: $vm.composerText,
                                   attachments: $attachments,
                                   isSending: vm.isSending) {
                let success = await vm.sendMessage(accessToken: store.testAccessToken, attachments: attachments)
                if success {
                    attachments = []
                }
            }
        }
        .navigationTitle("Ticket #\(vm.ticket.id)")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            vm.start(accessToken: store.testAccessToken)
        }
        .onDisappear {
            vm.stop()
        }
        .fullScreenCover(Binding(get: { selectedMedia != nil }, set: { if !$0 { selectedMedia = nil } })) {
            NavigationStack {
                if let media = selectedMedia {
                    SupportMedia(mediaPath: media, accessToken: store.testAccessToken) {
                        selectedMedia = nil
                    }
                }
            }
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

#Preview {
    NavigationStack {
        SupportTicketDetails(.init(id: 1, title: "Example issue", status: "open", userId: 1, createdAt: "2024-01-01T10:00:00Z", updatedAt: "2024-01-01T10:00:00Z"))
    }
    .environmentObject(ValueStore())
    .darkSchemePreferred()
}
