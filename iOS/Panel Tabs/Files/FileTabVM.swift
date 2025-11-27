import ScrechKit
import Combine
import PteroNet

final class FileTabVM: ObservableObject {
    private let id: String
    
    init(_ id: String) {
        self.id = id
        
#if !os(watchOS) && !os(tvOS)
        fileUploader.$uploadProgress
            .receive(on: DispatchQueue.main)
            .assign(to: \.uploadProgress, on: self)
            .store(in: &cancellables)
#endif
    }
    
#if !os(watchOS) && !os(tvOS)
    private var fileUploader = FileUploader()
    private var cancellables = Set<AnyCancellable>()
    @Published var uploadProgress: Float = 0
    @Published var isUploading = false
#endif
    
#if os(macOS)
    @Published var degrees = 0.0
#endif
    
    @Published var files: [FileAttributes] = []
    @Published var showTextField = false
    @Published var downloadUrl = ""
    @Published var path = ""
    @Published var showSafari = false
    @Published var newFolderName = ""
    @Published var searchField = ""
    @Published var newFileName = ""
    
    var fileCount: Int {
        filteredFiles.count
    }
    
    var filteredFiles: [FileAttributes] {
        if searchField.isEmpty {
            files
        } else {
            files.filter {
                $0.name
                    .localizedStandardContains(searchField)
            }
        }
    }
    
    func deleteItem(_ offsets: IndexSet) {
        for file in offsets {
            let name = filteredFiles[file].name
            
            Task {
                await deleteFile(name, at: path)
            }
        }
    }
    
    func chmod(
        _ read: Bool,
        _ write: Bool,
        _ execute: Bool
    ) -> String {
        var permission: UInt8 = 0
        
        if read    { permission |= 4 }
        if write   { permission |= 2 }
        if execute { permission |= 1 }
        
        return String(permission)
    }
    
    func changeChmod(
        _ file: String,
        at root: String,
        mode: String,
        onSuccess: @escaping () -> ()
    ) async {
        do {
            try await fileChmodAPI(id, file: file, at: root, mode: mode)
            onSuccess()
            await fetchFiles(root)
            
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func pullRemoteFile(
        _ file: FilePullRequestBody,
        at path: String = "",
        onSuccess: @escaping () -> ()
    ) async {
        do {
            try await pullRemoteFileAPI(id, file: file)
            
            onSuccess()
            
            await fetchFiles(path)
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func fetchFiles(_ path: String = "") async {
        do {
            let files = try await fileListAPI(id, path: path)
            
            await MainActor.run {
                self.files = files.reversed()
#if os(macOS)
                degrees += 360
#endif
            }
        } catch {
            SystemAlert.error(error)
        }
    }
    
#if os(iOS)
    func cancelUpload() {
        fileUploader.cancelUpload()
    }
    
    func uploadFile(
        _ urlString: String,
        name: String,
        at root: String,
        mimeType: String,
        fileUrl: URL
    ) {
        withAnimation {
            self.isUploading = true
        }
        
        self.fileUploader.uploadFile(
            urlString + "&directory=\(root.applyPercentEncoding())",
            name: name,
            mimeType: mimeType,
            fileURL: fileUrl
        )
        
        Task {
            try await Task.sleep(for: .seconds(2))
            
            withAnimation {
                self.isUploading = false
            }
            
            self.uploadProgress = 0
            
            await self.fetchFiles(root)
        }
    }
    
    func handleFileImport(
        _ urls: [URL],
        at root: String,
        onSuccess: @escaping () -> Void = {}
    ) async {
        for fileUrl in urls {
            let fileName = fileUrl.lastPathComponent
            
            guard let mimeType = getMimeType(fileUrl) else {
                print("Unable to determine MIME type for file:", fileName)
                continue
            }
            
            do {
                let url = try await fileUploadAPI(id)
                
                self.uploadFile(
                    url,
                    name: fileName,
                    at: root,
                    mimeType: mimeType,
                    fileUrl: fileUrl
                )
                
                await fetchFiles(root)
                
                onSuccess()
            } catch {
                print("Error in file API:", error)
            }
        }
    }
    
    func handleImageImport(
        _ image: UIImage,
        at root: String
    ) async {
        guard let imageData = image.heicData() else {
            print("Unable to convert image to data")
            return
        }
        
        let mimeType = "image/heic"
        let tempDirURL = FileManager.default.temporaryDirectory
        let fileURL = tempDirURL.appendingPathComponent("Image")
        
        do {
            try imageData.write(to: fileURL, options: .completeFileProtection)
        } catch {
            print("Could not write image data to temporary file:", error)
            return
        }
        
        do {
            let url = try await fileUploadAPI(id)
            
            self.uploadFile(
                url,
                name: "Image\(UUID().uuidString).heic",
                at: root,
                mimeType: mimeType,
                fileUrl: fileURL
            )
            
            await fetchFiles(root)
            
        } catch {
            SystemAlert.error(error)
        }
    }
#endif
    
    func downloadFile(_ path: String) async {
        do {
            downloadUrl = try await fileDownloadAPI(id, path: path)
            self.showSafari = true
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func renameFile(
        _ path: String,
        from oldName: String,
        to newName: String
    ) async {
        do {
            try await fileRenameAPI(id, at: path, from: oldName, to: newName)
            await fetchFiles(path)
            
            self.newFileName = ""
        } catch {
            SystemAlert.error(error)
            
        }
    }
    
    func duplicateFile(_ file: String, at path: String) async {
        do {
            try await fileDuplicateAPI(id, file: file, at: path)
            await fetchFiles(path)
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func fileCompressor(
        _ file: String,
        at path: String,
        do action: CompressorActions
    ) async {
        do {
            try await fileCompressorAPI(
                id,
                file: file,
                at: path,
                do: action
            )
            
            await fetchFiles(path)
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func createFolder(_ file: String, at path: String) async {
        do {
            try await fileCreateFolderAPI(id, file: file, at: path)
            
            await fetchFiles(path)
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func deleteFile(
        _ files: String,
        at path: String,
        onSuccess: @escaping (() -> Void) = {}
    ) async {
        do {
            try await fileDeleteAPI(id, files: [files], at: path)
            
            await fetchFiles(path)
            
            onSuccess()
        } catch {
            SystemAlert.error(error)
        }
    }
}
