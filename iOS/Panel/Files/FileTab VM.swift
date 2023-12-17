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
    
    @Published var files: [FileListData] = []
    @Published var degrees = 0.0
    @Published var toolbarId = "" // Requred for toolbar in order to update file list properly
    @Published var showTextField = false
    @Published var downloadUrl = ""
    @Published var showSafari = false
    @Published var newFolderName = ""
    @Published var fieldSearch = ""
    @Published var searchRule = ""
    //    @Published var alertRename = false
    //    @Published var newFileName = ""
    
    var filteredFiles: [FileListData] {
        if searchRule.isEmpty {
            files
        } else {
            files.filter {
                $0.attributes.name
                    .lowercased()
                    .contains(searchRule.lowercased())
            }
        }
    }
    
#if os(iOS)
    func uploadFile(
        _ urlString: String,
        name: String,
        directory: String,
        mimeType: String,
        fileUrl: URL
    ) {
        main {
            withAnimation {
                self.isUploading = true
            }
            
            self.fileUploader.uploadFile(
                urlString + "&directory=\(directory.applyPercentEncoding())",
                name: name,
                mimeType: mimeType,
                fileUrl: fileUrl
            )
            
            delay(2) {
                withAnimation {
                    self.isUploading = false
                }
                
                self.uploadProgress = 0
            }
        }
    }
    
    func handleFileImport(_ urls: [URL], directory: String) {
        for fileURL in urls {
            let fileName = fileURL.lastPathComponent
            
            guard let mimeType = getMimeType(fileURL) else {
                print("Unable to determine MIME type for file: \(fileName)")
                continue
            }
            
            uploadFileAPI(id) { result in
                switch result {
                case .success(let vm):
                    if let vm {
                        let url = vm.attributes.url
                        
                        self.uploadFile(
                            url,
                            name: fileName,
                            directory: directory,
                            mimeType: mimeType,
                            fileUrl: fileURL
                        )
                        
                        self.fetchFiles(directory)
                    }
                    
                case .failure(let error):
                    print("Error in file API: \(error)")
                }
            }
        }
    }
    
    func handleImageImport(_ image: UIImage, directory: String) {
        guard let imageData = image.jpegData(compressionQuality: 0.9) else {
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
            case .success(let vm):
                if let vm {
                    let url = vm.attributes.url
                    
                    self.uploadFile(
                        url,
                        name: "Image\(UUID().uuidString).jpeg",
                        directory: directory,
                        mimeType: mimeType,
                        fileUrl: fileURL
                    )
                    
                    self.fetchFiles(directory)
                }
                
            case .failure(let error):
                print("Error in file API: \(error)")
            }
        }
    }
#endif
    
    func downloadFile(_ path: String) {
        downloadFileAPI(id, from: path) { result in
            switch result {
            case .success(let model):
                if let model {
                    self.downloadUrl = model.attributes.url
                    self.showSafari = true
                }
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    //    func renameFile(_ path: String, oldName: String, newName: String) {
    //        renameFileAPI(id, from: path, oldName: oldName, newName: newName) { result in
    //            switch result {
    //            case .success:
    //                print("\n File \(oldName) renamed to \(newName)")
    //                self.fetchFiles(path)
    //
    //                main {
    //                    self.newFileName = ""
    //                }
    //
    //            case .failure(let error):
    //                networkCallError(#function, error)
    //            }
    //        }
    //    }
    
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
    
#if os(macOS)
    func fetchFiles(_ path: String = "") {
        getFileListAPI(id, from: path) { result in
            switch result {
            case .success(let vm):
                if let vm {
                    withAnimation(.easeInOut) {
                        self.degrees += 360
                        self.files = vm.data
                    }
                }
                
            case .failure(let error):
                withAnimation {
                    self.files.removeAll()
                }
                
                networkCallError(#function, error)
            }
        }
    }
#else
    func fetchFiles(_ path: String = "") {
        getFileListAPI(id, from: path) { result in
            switch result {
            case .success(let vm):
                main {
                    if let vm {
                        withAnimation {
                            self.files = vm.data
                        }
                    }
                }
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
#endif
    
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
