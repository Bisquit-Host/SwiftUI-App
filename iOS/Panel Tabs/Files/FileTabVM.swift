import ScrechKit
import Calagopus

final class FileTabVM: ObservableObject {
    private let id: String
    
    init(_ id: String) {
        self.id = id
        
#if os(iOS)
        fileUploader.setProgressHandler { [weak self] progress in
            self?.uploadProgress = progress
        }
#endif
    }
    
#if os(iOS)
    private var fileUploader = CalagopusFileUploader()
    @Published var uploadProgress: Float = 0
    @Published var isUploading = false
    @Published var uploadingCount: Int = 0
#endif
    
#if os(macOS)
    @Published var degrees = 0.0
#endif
    
    @Published var files: [CalagopusFileEntry] = []
    @Published var isLoadingFiles = false
    @Published var downloadURL = ""
    @Published var path = ""
    @Published var showSafari = false
    @Published var searchField = ""
    @Published var newFileName = ""
    @Published var deleteSuccessHapticTrigger = false
    
    var fileCount: Int {
        filteredFiles.count
    }
    
    var filteredFiles: [CalagopusFileEntry] {
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
            try await CalagopusNet.client().chmodFiles(
                server: id,
                root: root,
                files: [.init(file: file, mode: mode)]
            )
            onSuccess()
            await fetchFiles(root)
            
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func pullRemoteFile(_ file: CalagopusRemoteFilePull, at path: String = "", onSuccess: @escaping () -> ()) async {
        do {
            try await CalagopusNet.client().pullRemoteFile(server: id, file: file)
            
            onSuccess()
            
            await fetchFiles(path)
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func fetchFiles(_ path: String = "") async {
        isLoadingFiles = true
        defer {
            isLoadingFiles = false
        }
        
        do {
            files = try await CalagopusNet.client().files(server: id, directory: path).entries.data.sorted {
                let leftIsFolder = $0.directory
                let rightIsFolder = $1.directory
                
                if leftIsFolder != rightIsFolder {
                    return leftIsFolder
                }
                
                return $0.name.localizedStandardCompare($1.name) == .orderedAscending
            }
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
    
    @discardableResult
    func uploadFile(name: String, at root: String, mimeType: String, fileURL: URL) async -> Bool {
        withAnimation {
            isUploading = true
        }
        
        defer {
            uploadingCount = max(0, uploadingCount - 1)
            
            withAnimation {
                isUploading = false
            }
            
            uploadProgress = 0
        }
        
        do {
            try await fileUploader.uploadFile(
                using: CalagopusNet.client(),
                server: id,
                directory: root,
                name: name,
                mimeType: mimeType,
                fileURL: fileURL
            )
            await fetchFiles(root)
            return true
        } catch {
            SystemAlert.error(error)
            return false
        }
    }
    
    func handleFileImport(_ urls: [URL], at root: String, onSuccess: @escaping () -> Void = {}) async {
        uploadingCount = urls.count
        
        for fileURL in urls {
            let fileName = fileURL.lastPathComponent
            
            guard let mimeType = getMimeType(fileURL) else {
                Logger().error("Unable to determine MIME type for file: \(fileName)")
                continue
            }
            
            if await uploadFile(name: fileName, at: root, mimeType: mimeType, fileURL: fileURL) {
                onSuccess()
            }
        }
        
        uploadingCount = 0
    }
    
    func handleImageImport(_ image: UIImage, at root: String) async {
        uploadingCount = 1
        
        guard let imageData = image.heicData() else {
            Logger().error("Unable to convert image to data")
            return
        }
        
        let mimeType = "image/heic"
        let tempDirURL = FileManager.default.temporaryDirectory
        let fileURL = tempDirURL.appendingPathComponent("Image")
        
        do {
            try imageData.write(to: fileURL, options: .completeFileProtection)
        } catch {
            Logger().error("Could not write image data to temporary file: \(error)")
            return
        }
        
        await uploadFile(
            name: "Image\(UUID().uuidString).heic",
            at: root,
            mimeType: mimeType,
            fileURL: fileURL
        )
        
        uploadingCount = 0
    }
#endif
    
    func downloadFile(_ path: String) async {
        do {
            downloadURL = try await CalagopusNet.client().fileDownloadURL(server: id, path: path)
            showSafari = true
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func localFileForSharing(_ path: String, name: String) async -> URL? {
        do {
            let downloadURL = try await CalagopusNet.client().fileDownloadURL(server: id, path: path)
            return await FileTabShareCache.localFile(from: downloadURL, name: name)
        } catch {
            SystemAlert.error(error)
            return nil
        }
    }
    
    func renameFile(_ path: String, from oldName: String, to newName: String) async {
        do {
            try await CalagopusNet.client().renameFile(server: id, root: path, from: oldName, to: newName)
            await fetchFiles(path)
            
            newFileName = ""
        } catch {
            SystemAlert.error(error)
            
        }
    }
    
    func duplicateFile(_ file: String, at path: String) async {
        do {
            try await CalagopusNet.client().duplicateFile(server: id, root: path, file: file)
            await fetchFiles(path)
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func fileCompressor(
        _ file: String,
        at path: String,
        do action: CalagopusFileArchiveAction,
        format: CalagopusFileArchiveFormat = .tarGz,
        name: String? = nil
    ) async {
        do {
            try await CalagopusNet.client().archiveFile(server: id, root: path, file: file, action: action, format: format, name: name)
            
            await fetchFiles(path)
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func createFolder(_ file: String, at path: String) async {
        do {
            try await CalagopusNet.client().createDirectory(server: id, root: path, name: file)
            
            await fetchFiles(path)
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func deleteFile(_ files: String, at path: String, onSuccess: @escaping (() -> Void) = {}) async {
        do {
            try await CalagopusNet.client().deleteFiles(server: id, root: path, files: [files])
            
            await fetchFiles(path)
            deleteSuccessHapticTrigger.toggle()
            onSuccess()
        } catch {
            SystemAlert.error(error)
        }
    }
}

private enum FileTabShareCache {
    static func localFile(from remoteURLString: String, name: String) async -> URL? {
        guard let remoteURL = URL(string: remoteURLString) else {
            Logger().error("Invalid URL: \(remoteURLString)")
            return nil
        }
        
        let shareDirectoryURL = URL.cachesDirectory
            .appending(path: "Shared Files", directoryHint: .isDirectory)
            .appending(path: UUID().uuidString, directoryHint: .isDirectory)
        let destinationURL = shareDirectoryURL.appending(path: name)
        
        do {
            try FileManager.default.createDirectory(at: shareDirectoryURL, withIntermediateDirectories: true)
            let (location, _) = try await URLSession.shared.download(from: remoteURL)
            try FileManager.default.moveItem(at: location, to: destinationURL)
            return destinationURL
        } catch {
            Logger().error("Error during file download: \(error)")
            return nil
        }
    }
}
