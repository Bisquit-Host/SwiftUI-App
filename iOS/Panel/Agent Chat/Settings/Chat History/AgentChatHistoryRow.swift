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
        .disabled(isDeleting || vm.isOpeningHistoryChat)
        .swipeActions(edge: .leading) {
            AsyncButton(archiveTitle, systemImage: archiveIcon) {
                await vm.setChatArchived(chat, archived: !chat.archived)
            }
            .disabled(isDeleting)
            .labelStyle(.iconOnly)
            .tint(.orange)
        }
        .swipeActions {
            AsyncButton("Delete", systemImage: "trash", role: .destructive) {
                await vm.deleteHistoryChat(chat)
            }
            .disabled(isDeleting)
            .labelStyle(.iconOnly)
        }
        .contextMenu {
            AsyncButton(archiveTitle, systemImage: archiveIcon) {
                await vm.setChatArchived(chat, archived: !chat.archived)
            }
            .disabled(isDeleting)
            
            AsyncButton("Delete", systemImage: "trash", role: .destructive) {
                await vm.deleteHistoryChat(chat)
            }
            .disabled(isDeleting)
        }
    }
    
    private var subtitle: String? {
        let parts = [
            updatedAtText,
            statusText
        ].compactMap(\.self)
        
        guard !parts.isEmpty else { return nil }
        
        return parts.joined(separator: " - ")
    }
    
    private var archiveTitle: String {
        chat.archived ? String(localized: "Unarchive") : String(localized: "Archive")
    }
    
    private var archiveIcon: String {
        chat.archived ? "tray.and.arrow.up" : "archivebox"
    }
    
    private var statusText: String? {
        switch chat.phase {
        case "running": String(localized: "Running")
        case "waiting_approval": String(localized: "Waiting for approval")
        default: nil
        }
    }
    
    private var updatedAtText: String? {
        guard let updatedAt = chat.updatedAt else { return nil }
        
        return updatedAt.formatted(date: .abbreviated, time: .shortened)
    }
}
