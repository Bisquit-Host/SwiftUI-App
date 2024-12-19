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
    @Published var sheetPreview = false
#endif
    
    // macOS
    @Published var degrees = 0.0
    
    @Published var files: [FileAttributes] = []
    @Published var showTextField = false
    @Published var downloadUrl = ""
    @Published var showSafari = false
    @Published var newFolderName = ""
    @Published var searchField = ""
    @Published var newFileName = ""
    
    var filteredFiles: [FileAttributes] {
        if searchField.isEmpty {
            files
        } else {
            files.filter {
                $0.name
                    .lowercased()
                    .contains(searchField.lowercased())
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
    
    func changeChmod(_ file: String, root: String, mode: String, onSuccess: @escaping () -> ()) {
        fileChmodAPI(id, root: root, file: file, mode: mode) { result in
            switch result {
            case .success:
                onSuccess()
                self.fetchFiles(root)
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
    
    func pullRemoteFile(
        _ url: String,
        directory: String = "",
        filename: String? = nil,
        useHeader: Bool = false,
        foreground: Bool? = nil
    ) {
        pullRemoteFileAPI(id, url: url, directory: directory, filename: filename, useHeader: useHeader, foreground: foreground) { result in
            switch result {
            case .success:
                self.fetchFiles(directory)
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
    
    func fetchFiles(_ path: String = "") {
        fileListAPI(id, path: path) { result in
            switch result {
            case .success(let model):
                if let model = model?.data {
                    withAnimation {
                        main {
#if os(macOS)
                            self.degrees += 360
#endif
                            self.files = model.map(\.attributes).reversed()
                        }
                    }
                }
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
    
#if os(iOS)
    func cancelUpload() {
        fileUploader.cancelUpload()
    }
    
    func uploadFile(
        _ urlString: String,
        name: String,
        root: String,
        mimeType: String,
        fileUrl: URL
    ) {
        main {
            withAnimation {
                self.isUploading = true
            }
            
            self.fileUploader.uploadFile(
                urlString + "&directory=\(root.applyPercentEncoding())",
                name: name,
                mimeType: mimeType,
                fileUrl: fileUrl
            )
            
            delay(2) {
                withAnimation {
                    self.isUploading = false
                }
                
                self.uploadProgress = 0
                self.fetchFiles(root)
            }
        }
    }
    
    func handleFileImport(_ urls: [URL], root: String) {
        for fileURL in urls {
            let fileName = fileURL.lastPathComponent
            
            guard let mimeType = getMimeType(fileURL) else {
                print("Unable to determine MIME type for file: \(fileName)")
                continue
            }
            
            fileUploadAPI(id) { result in
                switch result {
                case .success(let model):
                    if let model = model?.attributes {
                        let url = model.url
                        
                        self.uploadFile(
                            url,
                            name: fileName,
                            root: root,
                            mimeType: mimeType,
                            fileUrl: fileURL
                        )
                        
                        self.fetchFiles(root)
                    }
                    
                case .failure(let error):
                    print("Error in file API: \(error)")
                }
            }
        }
    }
    
    func handleImageImport(_ image: UIImage, root: String) {
        guard let imageData = image.heicData() else {
            print("Unable to convert image to data")
            return
        }
        
        let mimeType = "image/heic"
        let temporaryDirectoryURL = FileManager.default.temporaryDirectory
        let fileURL = temporaryDirectoryURL.appendingPathComponent("Image")
        
        do {
            try imageData.write(to: fileURL, options: .completeFileProtection)
        } catch {
            print("Could not write image data to temporary file: \(error)")
            return
        }
        
        fileUploadAPI(id) { result in
            switch result {
            case .success(let model):
                if let vm = model?.attributes {
                    let url = vm.url
                    
                    self.uploadFile(
                        url,
                        name: "Image\(UUID().uuidString).heic",
                        root: root,
                        mimeType: mimeType,
                        fileUrl: fileURL
                    )
                    
                    self.fetchFiles(root)
                }
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
#endif
    
    func downloadFile(_ path: String) {
        fileDownloadAPI(id, path: path) { result in
            switch result {
            case .success(let model):
                if let model = model?.attributes {
                    main {
                        self.downloadUrl = model.url
                        self.showSafari = true
                    }
                }
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
    
    func renameFile(_ root: String, oldName: String, newName: String) {
        fileRenameAPI(id, root: root, oldName: oldName, newName: newName) { result in
            switch result {
            case .success:
                self.fetchFiles(root)
                
                main {
                    self.newFileName = ""
                }
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
    
    func duplicateFile(_ file: String, root: String) {
        fileDuplicateAPI(id, file: file, root: root) { result in
            switch result {
            case .success:
                self.fetchFiles(root)
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
    
    func fileCompressor(_ file: String, root: String, action: CompressorActions) {
        fileCompressorAPI(id, file: file, root: root, do: action) { result in
            switch result {
            case .success:
                self.fetchFiles(root)
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
    
    func createFolder(_ file: String, root: String) {
        fileCreateFolderAPI(id, file: file, root: root) { result in
            switch result {
            case .success:
                self.fetchFiles(root)
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
    
    func deleteFile(
        _ files: String,
        at root: String,
        onSuccess: @escaping (() -> Void) = {}
    ) {
        fileDeleteAPI(id, files: [files], root: root) { result in
            switch result {
            case .success:
                self.fetchFiles(root)
                
                DispatchQueue.main.async {
                    onSuccess()
                }
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
}
