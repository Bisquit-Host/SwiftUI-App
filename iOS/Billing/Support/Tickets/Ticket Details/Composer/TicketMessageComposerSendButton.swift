import SwiftUI

struct TicketMessageComposerSendButton: View {
    @Binding var text: String
    @Binding var attachments: [PendingAttachment]
    var isSending: Bool
    var onSend: () async -> Void
    
    private var sendDisabled: Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return (trimmed.isEmpty && attachments.isEmpty) || isSending
    }
    
    var body: some View {
        Button {
            Task {
                await onSend()
            }
        } label: {
            Image(systemName: isSending ? "paperplane.fill" : "paperplane")
                .footnote()
        }
        .frame(32)
        .glassEffect(in: .circle)
        .disabled(sendDisabled)
    }
}

//#Preview {
//    TicketMessageSendButton()
//        .darkSchemePreferred()
//}
