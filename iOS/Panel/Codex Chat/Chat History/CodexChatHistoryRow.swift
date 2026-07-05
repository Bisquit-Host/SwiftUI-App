import ScrechKit

struct CodexChatHistoryRow: View {
    @Environment(CodexChatVM.self) private var vm
    
    private let chat: CodexChatSummary
    
    init(_ chat: CodexChatSummary) {
        self.chat = chat
    }
    
    var body: some View {
        Button {
            Task {
                await vm.openHistoryChat(chat)
            }
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
