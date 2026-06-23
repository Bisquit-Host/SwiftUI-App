import ScrechKit
import Calagopus

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
    private var fileUploader = AppFileUploader()
    @Published var uploadProgress: Float = 0
    @Published var isUploading = false
    @Published var uploadingCount: Int = 0
#endif
    
#if os(macOS)
    @Published var degrees = 0.0
#endif
    
    @Published var files: [CalagopusFileEntry] = []
    @Published var isLoadingFiles = false
    @Published var showTextField = false
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
    
    func uploadFile(_ urlString: String, name: String, at root: String, mimeType: String, fileURL: URL) async {
        withAnimation {
            isUploading = true
        }
        
        guard var components = URLComponents(string: urlString) else {
            Logger().info("Invalid upload URL: \(urlString)")
            
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
            Logger().error("Failed to build upload URL with directory: \(root)")
            
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
                Logger().error("Unable to determine MIME type for file: \(fileName)")
                continue
            }
            
            do {
                let url = try await CalagopusNet.client().fileUploadURL(server: id)
                
                await self.uploadFile(url, name: fileName, at: root, mimeType: mimeType, fileURL: fileURL)
                onSuccess()
            } catch {
                Logger().error("Error in file API: \(error)")
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
        
        do {
            let url = try await CalagopusNet.client().fileUploadURL(server: id)
            
            await uploadFile(url, name: "Image\(UUID().uuidString).heic", at: root, mimeType: mimeType, fileURL: fileURL)
        } catch {
            SystemAlert.error(error)
        }
        
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
    
    func fileCompressor(_ file: String, at path: String, do action: CalagopusFileArchiveAction) async {
        do {
            try await CalagopusNet.client().archiveFile(server: id, root: path, file: file, action: action)
            
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

#if !os(watchOS) && !os(tvOS)
@MainActor
private final class AppFileUploader: NSObject {
    private var progressHandler: ((Float) -> Void)?
    private var session: URLSession!
    private var currentUploadTask: URLSessionUploadTask?
    
    private var uploadProgress: Float = 0 {
        didSet {
            progressHandler?(uploadProgress)
        }
    }
    
    private enum UploadError: LocalizedError {
        case failedToReadFile, failedToWriteTemp, badStatusCode(Int)
        
        var errorDescription: String? {
            switch self {
            case .failedToReadFile:
                "Failed to read file"
            case .failedToWriteTemp:
                "Failed to write temporary upload file"
            case .badStatusCode(let statusCode):
                "Upload failed with status \(statusCode)"
            }
        }
    }
    
    func cancelUpload() {
        currentUploadTask?.cancel()
        currentUploadTask = nil
    }
    
    func setProgressHandler(_ handler: @escaping (Float) -> Void) {
        progressHandler = handler
    }
    
    func uploadFile(_ url: URL, name: String, mimeType: String, fileURL: URL) async throws {
        let accessFiles = fileURL.startAccessingSecurityScopedResource()
        
        defer {
            if accessFiles {
                fileURL.stopAccessingSecurityScopedResource()
            }
        }
        
        guard let fileData = try? Data(contentsOf: fileURL) else {
            throw UploadError.failedToReadFile
        }
        
        let boundary = "----Boundary\(UUID().uuidString)"
        let multipartData = AppMultipartFormData(fileData, fileName: name, mimeType: mimeType, boundary: boundary).data
        let tempFileURL = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        
        do {
            try multipartData.write(to: tempFileURL)
        } catch {
            throw UploadError.failedToWriteTemp
        }
        
        session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                let task = session.uploadTask(with: request, fromFile: tempFileURL) { _, response, error in
                    try? FileManager.default.removeItem(at: tempFileURL)
                    
                    Task { @MainActor in
                        self.currentUploadTask = nil
                    }
                    
                    if let error {
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
                        continuation.resume(throwing: UploadError.badStatusCode(http.statusCode))
                        return
                    }
                    
                    continuation.resume()
                }
                
                currentUploadTask = task
                task.resume()
            }
        } onCancel: {
            Task { @MainActor in
                self.currentUploadTask?.cancel()
            }
        }
    }
}

extension AppFileUploader: @preconcurrency URLSessionDataDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        uploadProgress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
    }
}

private struct AppMultipartFormData {
    let data: Data
    
    init(_ fileData: Data, fileName: String, mimeType: String, boundary: String) {
        var fullData = Data()
        
        fullData.append(Data("--\(boundary)\r\n".utf8))
        fullData.append(Data("Content-Disposition: form-data; name=\"files\"; filename=\"\(fileName)\"\r\n".utf8))
        fullData.append(Data("Content-Type: \(mimeType)\r\n\r\n".utf8))
        fullData.append(fileData)
        fullData.append(Data("\r\n--\(boundary)--\r\n".utf8))
        
        data = fullData
    }
}
#endif
