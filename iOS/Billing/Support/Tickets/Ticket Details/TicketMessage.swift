import ScrechKit
import BisquitoNet

struct TicketMessage: View {
    let message: SupportMessageDTO
    let isCurrentUser: Bool
    var isDeleting = false
    var onMediaTap: (String) -> Void = { _ in }
    var onDelete: () -> Void = {}
    
    @State private var showDeleteAlert = false
    
    var body: some View {
        HStack {
            if isCurrentUser {
                Spacer(minLength: 40)
            }
            
            bubble
            
            if !isCurrentUser {
                Spacer(minLength: 40)
            }
        }
        .contextMenu {
            if isCurrentUser {
                Button("Delete", systemImage: "trash", role: .destructive) {
                    showDeleteAlert = true
                }
                .disabled(isDeleting)
            }
        }
        .alert("Delete message?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive, action: onDelete)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This message will be removed from the ticket")
        }
    }
    
    private var bubbleBackground: Color {
        isCurrentUser ? Color.accentColor.opacity(0.5) : Color.secondary.opacity(0.08)
    }
    
    private var bubble: some View {
        VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 0) {
            let text = message.message ?? ""
            let media = message.media ?? []
            
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 2) {
                if !isCurrentUser {
                    Text(message.user.name)
                        .caption(.semibold)
                        .secondary()
                }
                
                if !text.isEmpty || !media.isEmpty {
                    VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 8) {
                        if !text.isEmpty {
                            Text(text)
                        }
                        
                        if !media.isEmpty {
                            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 6) {
                                ForEach(media, id: \.self) { item in
                                    Button {
                                        onMediaTap(item)
                                    } label: {
                                        Label(item.replacing("media/tickets/", with: ""), systemImage: "paperclip")
                                            .caption()
                                            .lineLimit(1)
                                            .labelIconToTitleSpacing(5)
                                    }
                                    .buttonStyle(.plain)
                                    .caption()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                    }
                }
                
                Text(timeSinceISO(message.createdAt))
                    .caption2()
                    .tertiary()
            }
            .padding(10)
#if !os(visionOS)
            .glassEffect(.regular.tint(bubbleBackground), in: .rect(cornerRadius: 12))
#endif
        }
        .frame(maxWidth: .infinity, alignment: isCurrentUser ? .trailing : .leading)
    }
}
