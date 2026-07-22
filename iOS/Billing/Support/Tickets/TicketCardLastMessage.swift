import ScrechKit
import BisquitoNet

struct TicketCardLastMessage: View {
    private let lastMessage: SupportMessageDTO?
    
    init(_ lastMessage: SupportMessageDTO?) {
        self.lastMessage = lastMessage
    }
    
    var body: some View {
        if let last = lastMessage {
            let sender = last.user.isSupport ? String(localized: "Support") : last.user.name
            let text = last.message ?? ""

            HStack(alignment: .top, spacing: 8) {
                Circle()
                    .fill(Color.accentColor.gradient)
                    .frame(width: 32, height: 32)
                    .overlay {
                        Text(sender.prefix(1).uppercased())
                            .caption(.semibold)
                            .foregroundStyle(.white)
                    }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(sender)
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
