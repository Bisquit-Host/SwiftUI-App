import SwiftUI

struct CreateTicketSheet: View {
    @Bindable var vm: SupportTicketsVM
    @Binding var showSheet: Bool
    @EnvironmentObject private var store: ValueStore
    
    @State private var title = ""
    @State private var message = ""
    
    var body: some View {
        Form {
            Section("Title") {
                TextField("Brief summary", text: $title)
            }
            
            Section("Message") {
                TextEditor(text: $message)
                    .frame(minHeight: 160)
            }
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
            if let _ = await vm.createTicket(accessToken: store.testAccessToken, title: title, message: message) {
                showSheet = false
                await vm.loadTickets(accessToken: store.testAccessToken)
            }
        }
    }
}
