import SwiftUI
import PhotosUI

struct SupportMessageComposer: View {
    @Binding var text: String
    @Binding var attachments: [PendingAttachment]
    var isSending: Bool
    var onSend: () async -> Void
    
    @State private var photoItem: PhotosPickerItem?
    @State private var showFileImporter = false
    
    var body: some View {
        VStack(spacing: 8) {
            if !attachments.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(attachments) {
                            SuportMediaAttachment(for: $0, in: $attachments)
                        }
                    }
                    .padding(.horizontal, 12)
                }
            }
            
            HStack(spacing: 12) {
                TextField("Type here...", text: $text, axis: .vertical)
                    .padding(10)
                    .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))
                
                menuButtons
                
                Button {
                    Task {
                        await onSend()
                    }
                } label: {
                    Image(systemName: isSending ? "paperplane.fill" : "paperplane")
                        .title3()
                        .padding(5)
                }
                .disabled(sendDisabled)
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
        }
        .padding(.top, 8)
        .background(.thinMaterial)
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
        .onChange(of: photoItem) { _, newValue in
            guard let item = newValue else { return }
            
            Task {
                if let attachment = await AttachmentFactory.from(photoItem: item) {
                    appendAttachments([attachment])
                }
            }
        }
    }
    
    private var menuButtons: some View {
        VStack {
            PhotosPicker(selection: $photoItem, matching: .images, photoLibrary: .shared()) {
                Image(systemName: "photo.on.rectangle")
                    .title3()
            }
            .buttonStyle(.bordered)
            
            Button {
                showFileImporter = true
            } label: {
                Image(systemName: "paperclip")
                    .title3()
            }
            .buttonStyle(.bordered)
        }
    }
    
    private var sendDisabled: Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return (trimmed.isEmpty && attachments.isEmpty) || isSending
    }
    
    private func appendAttachments(from urls: [URL]) async {
        let mapped = urls.compactMap {
            AttachmentFactory.from(url: $0)
        }
        
        appendAttachments(mapped)
    }
    
    private func appendAttachments(_ new: [PendingAttachment]) {
        var combined = attachments
        combined.append(contentsOf: new)
        
        attachments = Array(combined.prefix(5))
    }
}

#Preview {
    @Previewable @State var message = "Preview message"
    @Previewable @State var files: [PendingAttachment] = []
    
    SupportMessageComposer(text: $message, attachments: $files, isSending: false) {}
        .darkSchemePreferred()
}
