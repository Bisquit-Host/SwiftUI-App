import SwiftUI
import PhotosUI

struct TicketMessageComposerPaperclip: View {
    @Binding private var attachments: [PendingAttachment]
    
    init(_ attachments: Binding<[PendingAttachment]>) {
        _attachments = attachments
    }
    
    @State private var showFileImporter = false
    @State private var showPhotoPicker = false
    @State private var photoItem: [PhotosPickerItem] = []
    
    var body: some View {
        Menu {
            Button("Photo Library", systemImage: "photo.on.rectangle") {
                showPhotoPicker = true
            }
            
            Button("Choose File", systemImage: "folder") {
                showFileImporter = true
            }
        } label: {
            Image(systemName: "paperclip")
                .title3()
                .foregroundStyle(.foreground)
        }
        .photosPicker(isPresented: $showPhotoPicker, selection: $photoItem, maxSelectionCount: 5, selectionBehavior: .ordered)
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
        .onChange(of: photoItem) { _, items in
            for item in items {
                Task {
                    if let attachment = await AttachmentFactory.from(photoItem: item) {
                        appendAttachments([attachment])
                    }
                }
            }
            
            photoItem = []
        }
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

//#Preview {
//    TicketMessagePaperclip()
//        .darkSchemePreferred()
//}
