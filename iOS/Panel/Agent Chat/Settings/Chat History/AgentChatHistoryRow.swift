import ScrechKit

struct AgentChatHistoryRow: View {
    @Environment(AgentChatVM.self) private var vm
    
    private let chat: AgentChatSummary
    
    init(_ chat: AgentChatSummary) {
        self.chat = chat
    }
    
    var body: some View {
        Button(action: openChat) {
            VStack(alignment: .leading) {
                Text(chat.title)
                
                if let subtitle {
                    Text(subtitle)
                        .secondary()
                }
            }
            .foregroundStyle(.foreground)
        }
        .disabled(isDeleting)
        .swipeActions {
            Button("Delete", systemImage: "trash", role: .destructive, action: deleteChat)
                .disabled(isDeleting)
                .labelStyle(.iconOnly)
        }
        .contextMenu {
            Button("Delete", systemImage: "trash", role: .destructive, action: deleteChat)
                .disabled(isDeleting)
        }
    }
    
    private var isDeleting: Bool {
        vm.isDeletingChat(chat)
    }
    
    private var subtitle: String? {
        let parts = [
            updatedAtText,
            chat.hasPendingApproval ? String(localized: "Waiting for approval") : nil
        ].compactMap(\.self)
        
        guard !parts.isEmpty else { return nil }
        
        return parts.joined(separator: " - ")
    }
    
    private var updatedAtText: String? {
        guard let updatedAt = chat.updatedAt else { return nil }
        
        return updatedAt.formatted(date: .abbreviated, time: .shortened)
    }
    
    private func openChat() {
        Task {
            await vm.openHistoryChat(chat)
        }
    }
    
    private func deleteChat() {
        Task {
            await vm.deleteHistoryChat(chat)
        }
    }
}
