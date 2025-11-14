import SwiftUI
import PhotosUI

struct UploadMenu: View {
    @EnvironmentObject private var vm: FileTabVM
    
    private let path: String
    
    init(_ path: String) {
        self.path = path
    }
    
    @State private var trigger = false
    
    @State private var image: UIImage?
    @State private var urls: [URL] = []
    @State private var previewUrls: [URL] = []
    @State private var pickerItems: [PhotosPickerItem] = []
    
    @State private var pickerFile = false
    @State private var pickerCamera = false
    @State private var pickerLibrary = false
    @State private var sheetRemoteFile = false
    
    var body: some View {
        Menu {
            Button("Choose File", systemImage: "folder") {
                pickerFile = true
            }
            
            Button("Take Photo", systemImage: "camera") {
                pickerCamera = true
            }
            
            Button("Photo Library", systemImage: "photo.on.rectangle") {
                pickerLibrary = true
            }
            
            Divider()
            
            Button("Pull remote file", systemImage: "link") {
                sheetRemoteFile = true
            }
        } label: {
            Image(systemName: "square.and.arrow.down")
        }
        .sensoryFeedback(.success, trigger: trigger)
        .cameraPicker($pickerCamera, image: $image)
        .photosPicker(
            isPresented: $pickerLibrary,
            selection: $pickerItems,
            selectionBehavior: .ordered
        )
        .onChange(of: pickerItems) { _, newItems in
            extractImageOrVideo(newItems)
        }
        .onChange(of: image) {
            if let image {
                Task {
                    await vm.handleImageImport(image, at: path)
                }
            }
        }
        .onChange(of: vm.isUploading) { _, newValue in
            if !newValue {
                trigger.toggle()
            }
        }
        .sheet($sheetRemoteFile) {
            NavigationStack {
                SheetRemoteFile(path)
            }
        }
        .fileImporter(
            isPresented: $pickerFile,
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
                        .replacing("public.", with: "")
                        .replacing("mpeg-4", with: "mp4")
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
        let tempDirURL = FileManager.default.temporaryDirectory
        
        let temporaryFileUrl = tempDirURL
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
