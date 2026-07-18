import SwiftUI
import PhotosUI

struct CodexChatImagePicker: View {
    @Environment(CodexChatVM.self) private var vm
    @State private var fileImporterPresented = false
    @State private var photoPickerPresented = false
    @State private var photoItems: [PhotosPickerItem] = []

    let disabled: Bool

    var body: some View {
        Menu {
            Button("Photo Library", systemImage: "photo.on.rectangle") {
                photoPickerPresented = true
            }

            Button("Choose File", systemImage: "folder") {
                fileImporterPresented = true
            }
        } label: {
            Image(systemName: "paperclip")
                .frame(35)
                .contentShape(.rect)
                .foregroundStyle(.foreground)
        }
        .disabled(disabled || vm.isImportingImages || vm.pendingImages.count >= CodexChatImageInput.maxCount)
        .photosPicker(
            isPresented: $photoPickerPresented,
            selection: $photoItems,
            maxSelectionCount: max(1, CodexChatImageInput.maxCount - vm.pendingImages.count),
            selectionBehavior: .ordered,
            matching: .images
        )
        .fileImporter(
            isPresented: $fileImporterPresented,
            allowedContentTypes: CodexChatImageInput.allowedContentTypes,
            allowsMultipleSelection: true
        ) {
            switch $0 {
            case .success(let urls):
                Task {
                    await vm.importImages(from: urls)
                }
            case .failure(let error):
                SystemAlert.error("File import failed", subtitle: error.localizedDescription)
            }
        }
        .onChange(of: photoItems) { _, items in
            guard !items.isEmpty else { return }

            Task {
                await vm.importImages(from: items)
                photoItems = []
            }
        }
    }
}
