import SwiftUI
import PhotosUI

struct CreateTicketSheet: View {
    @Environment(SupportTicketsVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    @Binding var showSheet: Bool
    
    @State private var title = ""
    @State private var message = ""
    @State private var attachments: [PendingAttachment] = []
    @State private var showFileImporter = false
    @State private var photoPickerItem: PhotosPickerItem?
    
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
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(file.filename)
                                    .lineLimit(1)
                                
                                Text(file.readableSize)
                                    .caption()
                                    .secondary()
                            }
                            
                            Spacer()
                            
                            Button(role: .destructive) {
                                attachments.removeAll { $0.id == file.id }
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                    }
                }
            }
            
            Section("Add Files") {
                HStack {
                    PhotosPicker(selection: $photoPickerItem, matching: .images, photoLibrary: .shared()) {
                        Label("Add Photo", systemImage: "photo")
                    }
                    
                    Button("Browse", systemImage: "paperclip") {
                        showFileImporter = true
                    }
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Up to 5 files. Allowed: png, jpg, jpeg, gif, svg, webp, txt, js, php, py, json, md")
                    .caption()
                    .secondary()
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
        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: AttachmentPicker.allowedTypes, allowsMultipleSelection: true) {
            switch $0 {
            case .success(let urls):
                Task {
                    await appendAttachments(from: urls)
                }
                
            case .failure(let error):
                SystemAlert.error("File import failed", subtitle: error.localizedDescription)
            }
        }
        .onChange(of: photoPickerItem) { _, newValue in
            guard let item = newValue else { return }
            
            Task {
                if let attachment = await AttachmentFactory.from(photoItem: item) {
                    appendAttachments([attachment])
                }
            }
        }
    }
    
    private func createTicket() {
        Task {
            if let _ = await vm.createTicket(accessToken: store.testAccessToken, title: title, message: message, attachments: attachments) {
                showSheet = false
                await vm.loadTickets(accessToken: store.testAccessToken)
            }
        }
    }
    
    private func appendAttachments(from urls: [URL]) async {
        let mapped = urls.compactMap { AttachmentFactory.from(url: $0) }
        appendAttachments(mapped)
    }
    
    private func appendAttachments(_ new: [PendingAttachment]) {
        var combined = attachments
        combined.append(contentsOf: new)
        attachments = Array(combined.prefix(5))
    }
}
