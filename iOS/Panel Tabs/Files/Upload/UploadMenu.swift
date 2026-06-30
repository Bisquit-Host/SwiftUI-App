import SwiftUI
import PhotosUI
import OSLog

struct UploadMenu: View {
    @EnvironmentObject private var vm: FileTabVM
    
    private let path: String
    
    init(_ path: String) {
        self.path = path
    }
    
    @State private var image: UIImage?
    @State private var pickerItems: [PhotosPickerItem] = []
    @State private var trigger = false
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
            Image(systemName: "document.badge.plus")
        }
        .sensoryFeedback(.success, trigger: trigger)
        .cameraPicker($pickerCamera, image: $image)
        .photosPicker(isPresented: $pickerLibrary, selection: $pickerItems, selectionBehavior: .ordered)
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
        .fileImporter(isPresented: $pickerFile, allowedContentTypes: [.item], allowsMultipleSelection: true) {
            switch $0 {
            case .success(let model):
                Task {
                    await vm.handleFileImport(model, at: path)
                }
                
            case .failure(let error):
                Logger().error("\(error)")
            }
        }
    }
    
    // MARK: Library funcs
    private func extractImageOrVideo(_ photoItems: [PhotosPickerItem]) {
        guard !photoItems.isEmpty else { return }
        
        Task {
            var tempURLs: [URL] = []
            
            for item in photoItems {
                guard let identifier = item.supportedContentTypes.first?
                    .identifier
                    .replacing("public.", with: "")
                    .replacing("mpeg-4", with: "mp4")
                else {
                    Logger().error("Extension not determined")
                    continue
                }
                
                Logger().info("Item: \(identifier)")
                
                guard let data = try? await item.loadTransferable(type: Data.self) else {
                    continue
                }
                
                if let url = writeDataToTemporaryURL(data, pathExtension: identifier) {
                    tempURLs.append(url)
                }
            }
            
            guard !tempURLs.isEmpty else { return }
            
            await vm.handleFileImport(tempURLs, at: path)
        }
        
        pickerItems = []
    }
    
    private func writeDataToTemporaryURL(_ data: Data, pathExtension: String = "") -> URL? {
        let tempDirURL = FileManager.default.temporaryDirectory
        
        let tempFileURL = tempDirURL
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(pathExtension)
        
        do {
            try data.write(to: tempFileURL)
            return tempFileURL
        } catch {
            Logger().error("Error writing video data to temporary file: \(error)")
            return nil
        }
    }
}
