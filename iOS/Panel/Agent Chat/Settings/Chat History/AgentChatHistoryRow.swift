import ScrechKit

struct AgentChatHistoryRow: View {
    @Environment(AgentChatVM.self) private var vm
    
    private let chat: AgentChatSummary
    
    init(_ chat: AgentChatSummary) {
        self.chat = chat
    }
    
    private var isDeleting: Bool {
        vm.isDeletingChat(chat)
    }
    
    var body: some View {
        AsyncButton {
            await vm.openHistoryChat(chat)
        } label: {
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
            AsyncButton("Delete", systemImage: "trash", role: .destructive) {
                await vm.deleteHistoryChat(chat)
            }
            .disabled(isDeleting)
            .labelStyle(.iconOnly)
        }
        .contextMenu {
            AsyncButton("Delete", systemImage: "trash", role: .destructive) {
                await vm.deleteHistoryChat(chat)
            }
            .disabled(isDeleting)
        }
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
}
