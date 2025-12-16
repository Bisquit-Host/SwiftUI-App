import ScrechKit

struct TicketMessage: View {
    let message: SupportMessageDTO
    let isCurrentUser: Bool
    var onMediaTap: (String) -> Void = { _ in }
    
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
    }
    
    private var bubbleBackground: Color {
        isCurrentUser ? Color.accentColor.opacity(0.5) : Color.secondary.opacity(0.08)
    }
    
    private var bubble: some View {
        VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 0) {
            let text = message.message ?? ""
            let media = message.media ?? []
            let hasContent = !text.isEmpty || !media.isEmpty
            
            HStack(spacing: 5) {
                Text(isCurrentUser ? "You" : message.user.name)
                    .caption(.semibold)
                
                Text("•")
                
                Text(timeSinceISO(message.createdAt))
                    .caption2()
            }
            .secondary()
            
            if hasContent {
                VStack(alignment: .leading, spacing: 8) {
                    if !text.isEmpty {
                        Text(text)
                    }
                    
                    if !media.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(media, id: \.self) { item in
                                Button {
                                    onMediaTap(item)
                                } label: {
                                    Label(item, systemImage: "paperclip")
                                        .caption()
                                        .lineLimit(2)
                                        .labelIconToTitleSpacing(5)
                                }
                                .buttonStyle(.plain)
                                .caption()
                            }
                        }
                    }
                }
                .padding(10)
                .glassEffect(.regular.tint(bubbleBackground), in: .rect(cornerRadius: 12))
            }
        }
        .frame(maxWidth: .infinity, alignment: isCurrentUser ? .trailing : .leading)
    }
}
