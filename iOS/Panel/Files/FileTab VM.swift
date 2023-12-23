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
    @Published var toolbarId = "" // Requred for toolbar in order to update file list properly
    @Published var showTextField = false
    @Published var downloadUrl = ""
    @Published var showSafari = false
    @Published var newFolderName = ""
    @Published var fieldSearch = ""
    @Published var searchRule = ""
    @Published var newFileName = ""
    
    var filteredFiles: [FileAttributes] {
        if searchRule.isEmpty {
            files
        } else {
            files.filter {
                $0.name
                    .lowercased()
                    .contains(searchRule.lowercased())
            }
        }
    }
    
#if os(iOS)
    func cancelUpload() {
        fileUploader.cancelUpload()
    }
    
    func uploadFile(_ urlString: String,
                    name: String,
                    path: String,
                    mimeType: String,
                    fileUrl: URL
    ) {
        main {
            withAnimation {
                self.isUploading = true
            }
            
            self.fileUploader.uploadFile(
                urlString + "&directory=\(path.applyPercentEncoding())",
                name: name,
                mimeType: mimeType,
                fileUrl: fileUrl
            )
            
            delay(2) {
                withAnimation {
                    self.isUploading = false
                }
                
                self.uploadProgress = 0
                self.fetchFiles(path)
            }
        }
    }
    
    func handleFileImport(_ urls: [URL], path: String) {
        for fileURL in urls {
            let fileName = fileURL.lastPathComponent
            
            guard let mimeType = getMimeType(fileURL) else {
                print("Unable to determine MIME type for file: \(fileName)")
                continue
            }
            
            uploadFileAPI(id) { result in
                switch result {
                case .success(let model):
                    if let model = model?.attributes {
                        let url = model.url
                        
                        self.uploadFile(url,
                                        name: fileName,
                                        path: path,
                                        mimeType: mimeType,
                                        fileUrl: fileURL)
                        
                        self.fetchFiles(path)
                    }
                    
                case .failure(let error):
                    print("Error in file API: \(error)")
                }
            }
        }
    }
    
    func handleImageImport(_ image: UIImage, path: String) {
        guard let imageData = image.jpegData(compressionQuality: 1) else {
            print("Unable to convert image to data")
            return
        }
        
        let mimeType = "image/jpeg"
        let temporaryDirectoryURL = FileManager.default.temporaryDirectory
        let fileURL = temporaryDirectoryURL.appendingPathComponent("Image")
        
        do {
            try imageData.write(to: fileURL, options: .completeFileProtection)
        } catch {
            print("Could not write image data to temporary file: \(error)")
            return
        }
        
        uploadFileAPI(id) { result in
            switch result {
            case .success(let model):
                if let vm = model?.attributes {
                    let url = vm.url
                    
                    self.uploadFile(url,
                                    name: "Image\(UUID().uuidString).jpeg",
                                    path: path,
                                    mimeType: mimeType,
                                    fileUrl: fileURL)
                    
                    self.fetchFiles(path)
                }
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
#endif
    
    func downloadFile(_ path: String) {
        downloadFileAPI(id, from: path) { result in
            switch result {
            case .success(let model):
                if let model = model?.attributes {
                    self.downloadUrl = model.url
                    self.showSafari = true
                }
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    func renameFile(_ path: String, oldName: String, newName: String) {
        renameFileAPI(id, from: path, oldName: oldName, newName: newName) { result in
            switch result {
            case .success:
                print("\n File \(oldName) renamed to \(newName)")
                self.fetchFiles(path)
                
                main {
                    self.newFileName = ""
                }
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    func duplicateFile(_ name: String, path: String) {
        duplicateFileAPI(id, name: name, from: path) { result in
            switch result {
            case .success:
                self.fetchFiles(path)
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    func fileCompressor(_ name: String, path: String, action: CompressorActions) {
        fileCompressorAPI(id, name: name, from: path, do: action) { result in
            switch result {
            case .success:
                self.fetchFiles(path)
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    func createFolder(_ name: String, path: String) {
        createFolderAPI(id, name: name, from: path) { result in
            switch result {
            case .success:
                self.fetchFiles(path)
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    func fetchFiles(_ path: String = "") {
        getFileListAPI(id, from: path) { result in
            switch result {
            case .success(let model):
                if let model = model?.data {
                    withAnimation {
                        main {
#if os(macOS)
                            self.degrees += 360
#endif
                            self.files = model.map {
                                $0.attributes
                            }
                        }
                    }
                }
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    func fileDelete(_ name: String, path: String) {
        deleteFileAPI(id, name: name, from: path) { result in
            switch result {
            case .success:
                self.fetchFiles(path)
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
}
