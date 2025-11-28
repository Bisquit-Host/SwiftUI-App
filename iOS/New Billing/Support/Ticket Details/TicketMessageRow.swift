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
            
            bubble
            
            if !isCurrentUser {
                Spacer(minLength: 40)
            }
        }
    }
    
    private var bubble: some View {
        VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 6) {
            let text = message.message ?? ""
            
            if !text.isEmpty {
                Text(text)
                    .padding(10)
                    .background(bubbleBackground, in: .rect(cornerRadius: 12))
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
                                .background(bubbleBackground, in: .rect(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                        .caption()
                    }
                }
            }
            
            HStack {
                if !isCurrentUser {
                    Text(message.user.name)
                        .caption(.semibold)
                        .secondary()
                }
                
                Text(message.createdAtRelative)
                    .caption2()
                    .secondary()
            }
        }
        .frame(maxWidth: .infinity, alignment: isCurrentUser ? .trailing : .leading)
    }
    
    private var bubbleBackground: Color {
        isCurrentUser ? Color.accentColor.opacity(0.15) : Color.secondary.opacity(0.08)
    }
}
