import ScrechKit

struct CreateTicketSheet: View {
    @Environment(TicketListVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var message = ""
    @State private var attachments: [PendingAttachment] = []
    
    private let navigationTitle: LocalizedStringKey
    private let titleSectionTitle: LocalizedStringKey
    private let titlePrompt: LocalizedStringKey
    private let isTitleEditable: Bool
    private let showsTitleSection: Bool
    private let isMessageRequired: Bool
    private let areAttachmentsOptional: Bool
    
    init(
        navigationTitle: LocalizedStringKey = "New Ticket",
        titleSectionTitle: LocalizedStringKey = "Title",
        titlePrompt: LocalizedStringKey = "Brief summary",
        title: String = "",
        isTitleEditable: Bool = true,
        showsTitleSection: Bool = true,
        isMessageRequired: Bool = true,
        areAttachmentsOptional: Bool = false
    ) {
        self.navigationTitle = navigationTitle
        self.titleSectionTitle = titleSectionTitle
        self.titlePrompt = titlePrompt
        self.isTitleEditable = isTitleEditable
        self.showsTitleSection = showsTitleSection
        self.isMessageRequired = isMessageRequired
        self.areAttachmentsOptional = areAttachmentsOptional
        _title = State(initialValue: title)
    }
    
    var body: some View {
        Form {
            if showsTitleSection {
                Section(titleSectionTitle) {
                    if isTitleEditable {
                        TextField(titlePrompt, text: $title)
                    } else {
                        Text(title)
                    }
                }
            }
            
            Section("Message") {
                TextEditor(text: $message)
                    .frame(minHeight: 160)
            }
            
            CreateTicketSheetAttachments($attachments, isOptional: areAttachmentsOptional)
            CreateTicketSheetFilePicker($attachments, isOptional: areAttachmentsOptional)
        }
        .navigationTitle(navigationTitle)
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
                        (isMessageRequired && message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    )
            }
        }
    }
    
    private func createTicket() {
        Task {
            if let _ = await vm.createTicket(title, message: message, attachments: attachments, requiresMessage: isMessageRequired) {
                dismiss()
                await vm.fetchTickets()
            }
        }
    }
}
