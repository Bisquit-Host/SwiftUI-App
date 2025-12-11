import SwiftUI

struct CreateTicketSheet: View {
    @Environment(SupportTicketListVM.self) private var vm
    
    @Binding var showSheet: Bool
    
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
            
            if !attachments.isEmpty {
                Section("Attachments (\(attachments.count)/5)") {
                    ForEach(attachments) { file in
                        CreateTicketSheetAttachment(file) {
                            attachments.removeAll { $0.id == file.id }
                        }
                    }
                }
            }
            
            CreateTicketSheetFilePicker($attachments)
        }
        .navigationTitle("New Ticket")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") {
                    showSheet = false
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
            if let _ = await vm.createTicket(title: title, message: message, attachments: attachments) {
                showSheet = false
                await vm.loadTickets()
            }
        }
    }
}
