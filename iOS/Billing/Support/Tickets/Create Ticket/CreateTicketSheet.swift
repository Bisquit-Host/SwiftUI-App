import SwiftUI

struct CreateTicketSheet: View {
    @Environment(TicketListVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var message = ""
    @State private var attachments: [PendingAttachment] = []
    
    var body: some View {
        Form {
            Section("Title") {
                TextField("Brief summary", text: $title)
            }
            
            Section("Message") {
                TextEditor(text: $message)
                    .frame(minHeight: 160)
            }
            
            CreateTicketSheetAttachments($attachments)
            CreateTicketSheetFilePicker($attachments)
        }
        .navigationTitle("New Ticket")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Submit") {
                    createTicket()
                }
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                          message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
    
    private func createTicket() {
        Task {
            if let _ = await vm.createTicket(title, message: message, attachments: attachments) {
                dismiss()
                await vm.fetchTickets()
            }
        }
    }
}
