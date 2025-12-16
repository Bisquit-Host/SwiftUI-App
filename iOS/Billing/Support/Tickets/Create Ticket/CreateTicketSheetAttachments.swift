import SwiftUI

struct CreateTicketSheetAttachments: View {
    @Binding private var attachments: [PendingAttachment]
    
    init(_ attachments: Binding<[PendingAttachment]>) {
        _attachments = attachments
    }
    
    var body: some View {
        if !attachments.isEmpty {
            Section("Attachments (\(attachments.count)/5)") {
                ForEach(attachments) { file in
                    CreateTicketSheetAttachment(file) {
                        attachments.removeAll { $0.id == file.id }
                    }
                }
            }
        }
    }
}

//#Preview {
//    CreateTicketSheetAttachments()
//        .darkSchemePreferred()
//}
