import ScrechKit
import PhotosUI

struct UploadMenu: View {
    @EnvironmentObject private var vm: FileTabVM
    
    @Binding private var image: UIImage?
    private let path: String
    
    init(
        _ image: Binding<UIImage?>,
        at path: String
    ) {
        _image = image
        self.path = path
    }
    
    @State private var showFilePicker = false
    @State private var showCameraPicker = false
    @State private var sheetRemoteFile = false
    @State private var urls: [URL] = []
    
    // Library
    @State private var showLibraryPicker = false
    @State private var pickerItems: [PhotosPickerItem] = []
    @State private var previewUrls: [URL] = []
    
    var body: some View {
        Menu {
            MenuButton("Choose File", icon: "folder") {
                showFilePicker = true
            }
            
            MenuButton("Take Photo", icon: "camera") {
                showCameraPicker = true
            }
            
            MenuButton("Photo Library", icon: "photo.on.rectangle") {
                showLibraryPicker = true
            }
            
            Divider()
            
            Button {
                sheetRemoteFile = true
            } label: {
                Label("Pull remote file", systemImage: "link")
            }
        } label: {
            HStack {
                Text("Upload file")
                
                Spacer()
                
                Image(systemName: "square.and.arrow.up")
                    .title3(.semibold)
            }
            .foregroundStyle(.foreground)
        }
        .cameraPicker($showCameraPicker, image: $image)
        .photosPicker(
            isPresented: $showLibraryPicker,
            selection: $pickerItems,
            selectionBehavior: .ordered
        )
        .onChange(of: pickerItems) { _, newItems in
            extractImageOrVideo(newItems)
        }
        .sheet($sheetRemoteFile) {
            SheetRemoteFile(path)
        }
        .fileImporter(
            isPresented: $showFilePicker,
            allowedContentTypes: [.item],
            allowsMultipleSelection: true
        ) { result in
            
            switch result {
            case .success(let model):
                urls = model
                
                Task {
                    await vm.handleFileImport(urls, at: path)
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
        if vm.isUploading {
            UploadProgress(previewUrls.count == 0 ? urls.count : previewUrls.count)
        }
    }
    
    // MARK: Library funcs
    private func extractImageOrVideo(
        _ photoItems: [PhotosPickerItem]
    ) {
        Task.detached {
            for item in photoItems {
                guard
                    let identifier = item.supportedContentTypes.first?
                        .identifier
                        .replacingOccurrences(of: "public.", with: "")
                        .replacingOccurrences(of: "mpeg-4", with: "mp4")
                else {
                    print("Extension not determined")
                    return
                }
                
                print("Item:", identifier)
                
                guard let data = try? await item.loadTransferable(type: Data.self) else {
                    return
                }
                
                await MainActor.run {
                    if let url = writeDataToTemporaryUrl(data, pathExtension: identifier) {
                        withAnimation {
                            previewUrls.append(url)
                        }
                    }
                }
            }
            
            await vm.handleFileImport(previewUrls, at: path)
        }
        
        pickerItems = []
        previewUrls = []
    }
    
    private func writeDataToTemporaryUrl(
        _ data: Data,
        pathExtension: String = ""
    ) -> URL? {
        let temporaryDirectoryUrl = FileManager.default.temporaryDirectory
        
        let temporaryFileUrl = temporaryDirectoryUrl
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(pathExtension)
        
        do {
            try data.write(to: temporaryFileUrl)
            return temporaryFileUrl
        } catch {
            print("Error writing video data to temporary file:", error)
            return nil
        }
    }
}
