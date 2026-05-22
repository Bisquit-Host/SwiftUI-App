import SwiftUI

struct CreateTicketSheetAttachments: View {
    @Binding private var attachments: [PendingAttachment]
    private let isOptional: Bool
    
    init(_ attachments: Binding<[PendingAttachment]>, isOptional: Bool = false) {
        _attachments = attachments
        self.isOptional = isOptional
    }
    
    var body: some View {
        if !attachments.isEmpty {
            if isOptional {
                Section("Attachments (optional) (\(attachments.count)/5)") {
                    ForEach(attachments) { file in
                        CreateTicketSheetAttachment(file) {
                            attachments.removeAll { $0.id == file.id }
                        }
                    }
                }
            } else {
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
}

//#Preview {
//    CreateTicketSheetAttachments()
//        .darkSchemePreferred()
//}
