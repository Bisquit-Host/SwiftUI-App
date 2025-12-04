import SwiftUI

struct SuportMediaAttachment: View {
    private let attachment: PendingAttachment
    @Binding var attachments: [PendingAttachment]
    
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
            
            Button {
                attachments.removeAll {
                    $0.id == attachment.id
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
            }
        }
        .padding(10)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))
    }
}

//#Preview {
//    SuportMediaAttachment()
//        .darkSchemePreferred()
//}
