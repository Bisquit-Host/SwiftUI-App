import ScrechKit

struct TicketMediaAttachment: View {
    private let attachment: PendingAttachment
    @Binding private var attachments: [PendingAttachment]
    
    init(for attachment: PendingAttachment, in attachments: Binding<[PendingAttachment]>) {
        self.attachment = attachment
        _attachments = attachments
    }
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "paperclip")
            
            VStack(alignment: .leading, spacing: 2) {
                Text(attachment.filename)
                    .lineLimit(1)
                
                Text(attachment.readableSize)
                    .caption()
                    .secondary()
            }
            
            SFButton("xmark.circle.fill") {
                attachments.removeAll {
                    $0.id == attachment.id
                }
            }
        }
        .padding(10)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))
    }
}

//#Preview {
//    TicketMediaAttachment()
//        .darkSchemePreferred()
//}
