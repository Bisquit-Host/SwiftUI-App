import SwiftUI
import PhotosUI

struct CreateTicketSheetFilePicker: View {
    @Binding private var attachments: [PendingAttachment]
    private let isOptional: Bool
    
    init(_ attachments: Binding<[PendingAttachment]>, isOptional: Bool = false) {
        _attachments = attachments
        self.isOptional = isOptional
    }
    
    @State private var showFileImporter = false
    @State private var showPhotoPicker = false
    @State private var photoPickerItem: PhotosPickerItem?
    
    var body: some View {
        if isOptional {
            Section("Attachments (optional)") {
                pickerButtons()
                attachmentLimitsText()
            }
        } else {
            Section("Attachments") {
                pickerButtons()
                attachmentLimitsText()
            }
        }
    }
    
    private func pickerButtons() -> some View {
        HStack {
            Button("Add Photo", systemImage: "photo") {
                showPhotoPicker = true
            }
            .photosPicker(isPresented: $showPhotoPicker, selection: $photoPickerItem, matching: .images, photoLibrary: .shared())
            .onChange(of: photoPickerItem) { _, newValue in
                guard let item = newValue else { return }
                
                Task {
                    if let attachment = await AttachmentFactory.from(photoItem: item) {
                        appendAttachments([attachment])
                    }
                }
            }
            
            Button("Add Files", systemImage: "paperclip") {
                showFileImporter = true
            }
            .fileImporter(isPresented: $showFileImporter, allowedContentTypes: AttachmentPicker.allowedTypes, allowsMultipleSelection: true) {
                switch $0 {
                case .success(let urls):
                    Task {
                        await appendAttachments(urls)
                    }
                    
                case .failure(let error):
                    SystemAlert.error("File import failed", subtitle: error.localizedDescription)
                }
            }
        }
        .buttonStyle(.bordered)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func attachmentLimitsText() -> some View {
        Text("Up to 5 files, max 5 MB each. Allowed: png, jpg, jpeg, gif, svg, webp, txt, js, php, py, json, md")
            .caption()
            .secondary()
    }
    
    private func appendAttachments(_ urls: [URL]) async {
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
//    CreateTicketSheetFilePicker()
//        .darkSchemePreferred()
//}
