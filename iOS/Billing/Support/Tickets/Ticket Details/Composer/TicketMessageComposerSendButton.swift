import ScrechKit

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
        AsyncButton(action: onSend) {
            Image(systemName: isSending ? "paperplane.fill" : "paperplane")
                .footnote()
                .frame(32)
        }
#if os(visionOS)
        .background(.thinMaterial, in: .circle)
#else
        .glassEffect(in: .circle)
#endif
        .disabled(sendDisabled)
    }
}

//#Preview {
//    TicketMessageSendButton()
//        .darkSchemePreferred()
//}
