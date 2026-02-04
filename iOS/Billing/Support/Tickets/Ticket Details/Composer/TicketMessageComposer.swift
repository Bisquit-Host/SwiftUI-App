import SwiftUI

struct TicketMessageComposer: View {
    @Binding var text: String
    @Binding var attachments: [PendingAttachment]
    var isSending: Bool
    var onSend: () async -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            TicketMessageComposerAttachments($attachments)
            
            HStack(spacing: 12) {
                TicketMessageComposerPaperclip($attachments)
                
                TextField("Type here...", text: $text, axis: .vertical)
                    .frame(height: 32)
                    .padding(.horizontal, 8)
                    .glassEffect()
                
                TicketMessageComposerSendButton(text: $text, attachments: $attachments, isSending: isSending, onSend: onSend)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
        }
        .padding(.top, 8)
    }
}

#Preview {
    @Previewable @State var message = "Preview message"
    @Previewable @State var files: [PendingAttachment] = []
    
    TicketMessageComposer(text: $message, attachments: $files, isSending: false) {}
        .darkSchemePreferred()
}
