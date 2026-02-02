import SwiftUI

struct TicketMessageComposerAttachments: View {
    @Binding private var attachments: [PendingAttachment]
    
    init(_ attachments: Binding<[PendingAttachment]>) {
        _attachments = attachments
    }
    
    var body: some View {
        if !attachments.isEmpty {
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(attachments) {
                        TicketMediaAttachment(for: $0, in: $attachments)
                    }
                }
                .padding(.horizontal, 12)
            }
            .scrollIndicators(.never)
        }
    }
}
