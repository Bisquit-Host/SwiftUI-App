import SwiftUI

struct TicketMessageComposerAttachments: View {
    @Binding private var attachments: [PendingAttachment]
    
    init(_ attachments: Binding<[PendingAttachment]>) {
        _attachments = attachments
    }
    
    var body: some View {
        if !attachments.isEmpty {
            VStack(spacing: 8) {
                ForEach(attachments) {
                    TicketMediaAttachment(for: $0, in: $attachments)
                }
            }
            .padding()
#if os(visionOS)
            .background(.thinMaterial, in: .rect(cornerRadius: 12))
#else
            .glassEffect(in: .rect(cornerRadius: 12))
#endif
        }
    }
}
