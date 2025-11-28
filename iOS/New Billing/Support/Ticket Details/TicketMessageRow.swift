import SwiftUI

struct TicketMessageRow: View {
    let message: SupportMessageDTO
    let isCurrentUser: Bool
    var onMediaTap: (String) -> Void = { _ in }
    
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
                let text = message.message ?? ""
                if !text.isEmpty {
                    Text(text)
                        .padding(10)
                        .background(isCurrentUser ? Color.accentColor.opacity(0.15) : Color.secondary.opacity(0.08), in: .rect(cornerRadius: 12))
                }
                
                if let media = message.media, !media.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(media, id: \.self) { item in
                            Button {
                                onMediaTap(item)
                            } label: {
                                Label(item, systemImage: "paperclip")
                                    .caption()
                                    .lineLimit(2)
                                    .padding(8)
                                    .background(.secondary.opacity(0.08), in: .rect(cornerRadius: 10))
                            }
                            .buttonStyle(.plain)
                                .caption()
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
