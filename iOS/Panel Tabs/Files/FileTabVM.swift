import ScrechKit
import PteroNet

final class FileTabVM: ObservableObject {
    private let id: String
    
    init(_ id: String) {
        self.id = id
        
#if !os(watchOS) && !os(tvOS)
        fileUploader.setProgressHandler { [weak self] progress in
            self?.uploadProgress = progress
        }
#endif
    }
    
#if !os(watchOS) && !os(tvOS)
    private var fileUploader = FileUploader()
    @Published var uploadProgress: Float = 0
    @Published var isUploading = false
    @Published var uploadingCount: Int = 0
#endif
    
#if os(macOS)
    @Published var degrees = 0.0
#endif
    
    @Published var files: [FileAttributes] = []
    @Published var showTextField = false
    @Published var downloadURL = ""
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
                $0.name.localizedStandardContains(searchField)
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
    
    func chmod(_ read: Bool, _ write: Bool, _ execute: Bool) -> String {
        var permission: UInt8 = 0
        
        if read    { permission |= 4 }
        if write   { permission |= 2 }
        if execute { permission |= 1 }
        
        return String(permission)
    }
    
    func changeChmod(_ file: String, at root: String, mode: String, onSuccess: @escaping () -> ()) async {
        do {
            try await fileChmodAPI(id, file: file, at: root, mode: mode)
            onSuccess()
            await fetchFiles(root)
            
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func pullRemoteFile(_ file: FilePullRequestBody, at path: String = "", onSuccess: @escaping () -> ()) async {
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
            files = try await fileListAPI(id, path: path).reversed()
#if os(macOS)
            degrees += 360
#endif
        } catch {
            SystemAlert.error(error)
        }
    }
    
#if os(iOS)
    func cancelUpload() {
        fileUploader.cancelUpload()
        uploadingCount = 0
        uploadProgress = 0
        
        withAnimation {
            isUploading = false
        }
    }
    
    func uploadFile(_ urlString: String, name: String, at root: String, mimeType: String, fileURL: URL) async {
        withAnimation {
            isUploading = true
        }
        
        guard var components = URLComponents(string: urlString) else {
            print("Invalid upload URL:", urlString)
            
            withAnimation {
                isUploading = false
            }
            
            uploadProgress = 0
            return
        }
        
        var queryItems = components.queryItems ?? []
        queryItems.append(URLQueryItem(name: "directory", value: root))
        components.queryItems = queryItems
        
        guard let uploadURL = components.url else {
            print("Failed to build upload URL with directory:", root)
            
            withAnimation {
                isUploading = false
            }
            
            uploadProgress = 0
            return
        }
        
        do {
            try await fileUploader.uploadFile(uploadURL, name: name, mimeType: mimeType, fileURL: fileURL)
            await fetchFiles(root)
        } catch {
            SystemAlert.error(error)
        }
        
        uploadingCount = max(0, uploadingCount - 1)
        
        withAnimation {
            isUploading = false
        }
        
        uploadProgress = 0
    }
    
    func handleFileImport(_ urls: [URL], at root: String, onSuccess: @escaping () -> Void = {}) async {
        uploadingCount = urls.count
        
        for fileURL in urls {
            let fileName = fileURL.lastPathComponent
            
            guard let mimeType = getMimeType(fileURL) else {
                print("Unable to determine MIME type for file:", fileName)
                continue
            }
            
            do {
                let url = try await fileUploadAPI(id)
                
                await self.uploadFile(url, name: fileName, at: root, mimeType: mimeType, fileURL: fileURL)
                onSuccess()
            } catch {
                print("Error in file API:", error)
            }
        }
        
        uploadingCount = 0
    }
    
    func handleImageImport(_ image: UIImage, at root: String) async {
        uploadingCount = 1
        
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
            
            await uploadFile(url, name: "Image\(UUID().uuidString).heic", at: root, mimeType: mimeType, fileURL: fileURL)
        } catch {
            SystemAlert.error(error)
        }
        
        uploadingCount = 0
    }
#endif
    
    func downloadFile(_ path: String) async {
        do {
            downloadURL = try await fileDownloadAPI(id, path: path)
            showSafari = true
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func renameFile(_ path: String, from oldName: String, to newName: String) async {
        do {
            try await fileRenameAPI(id, at: path, from: oldName, to: newName)
            await fetchFiles(path)
            
            newFileName = ""
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
    
    func fileCompressor(_ file: String, at path: String, do action: CompressorActions) async {
        do {
            try await fileCompressorAPI(id, file: file, at: path, do: action)
            
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
    
    func deleteFile(_ files: String, at path: String, onSuccess: @escaping (() -> Void) = {}) async {
        do {
            try await fileDeleteAPI(id, files: [files], at: path)
            
            await fetchFiles(path)
            onSuccess()
        } catch {
            SystemAlert.error(error)
        }
    }
}
