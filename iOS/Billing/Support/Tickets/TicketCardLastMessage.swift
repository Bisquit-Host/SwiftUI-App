import ScrechKit
import BisquitoNet

struct TicketCardLastMessage: View {
    private let lastMessage: SupportMessageDTO?
    
    init(_ lastMessage: SupportMessageDTO?) {
        self.lastMessage = lastMessage
    }
    
    var body: some View {
        if let last = lastMessage {
            let text = last.message ?? ""

            HStack(alignment: .top, spacing: 8) {
                TicketCardAvatar(last.user)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(last.user.name)
                            .subheadline(.medium)

                        Spacer()

                        Text(timeSinceISO(last.createdAt))
                            .caption2()
                            .foregroundStyle(.tertiary)
                    }

                    Text(text.isEmpty ? String(localized: "Attachment") : text)
                        .subheadline()
                        .secondary()
                        .lineLimit(2)
                }
            }
        } else {
            Text("No messages yet")
                .subheadline()
                .foregroundStyle(.tertiary)
                .italic()
        }
    }
}

//#Preview {
//    TicketCardLastMessage()
//        .darkSchemePreferred()
//}
