import ScrechKit

struct CreateTicketSheet: View {
    @Environment(TicketListVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var message = ""
    @State private var attachments: [PendingAttachment] = []
    
    private let purpose: CreateTicketPurpose
    
    init(_ purpose: CreateTicketPurpose = .standard) {
        self.purpose = purpose
        _title = State(initialValue: purpose.initialTitle)
    }
    
    var body: some View {
        Form {
            if purpose.showsTitleSection {
                Section("Title") {
                    TextField("Brief summary", text: $title)
                }
            }
            
            Section("Message") {
                TextEditor(text: $message)
                    .frame(minHeight: 160)
            }
            
            CreateTicketSheetAttachments($attachments, isOptional: purpose.areAttachmentsOptional)
            CreateTicketSheetFilePicker($attachments, isOptional: purpose.areAttachmentsOptional)
        }
        .navigationTitle(purpose.navigationTitle)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                SFButton("xmark") {
                    dismiss()
                }
                .tint(.red)
            }
            
            ToolbarItem(placement: .confirmationAction) {
                SFButton("checkmark", action: createTicket)
                    .disabled(
                        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                        (purpose.isMessageRequired && message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    )
            }
        }
    }
    
    private func createTicket() {
        Task {
            if let _ = await vm.createTicket(
                title,
                message: message,
                attachments: attachments,
                requiresMessage: purpose.isMessageRequired
            ) {
                dismiss()
                await vm.fetchTickets()
            }
        }
    }
}
