import ScrechKit
import PteroNet

@Observable
final class QuickLookFileVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var fileURL: URL? = nil
    var isSensitive = false
    var metadata: [URLResourceKey: Any]? = nil
    
    func downloadFile(_ file: String, root: String) {
        fileDownloadAPI(id, path: root + "/\(file)") { result in
            switch result {
            case .success(let model):
                if let model = model?.attributes.url {
                    self.downloadVideo(model, name: file)
                }
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
    
    private func downloadVideo(_ urlString: String, name: String) {
        let fm = FileManager.default
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let tempDirectoryURL = fm.temporaryDirectory
        let destinationURL = tempDirectoryURL.appendingPathComponent(name)
        
        URLSession.shared.downloadTask(with: url) { location, response, error in
            let fm = FileManager.default
            
            guard let location, error == nil else {
                print("Download error: \(error?.localizedDescription ?? "No error description available")")
                return
            }
            
            do {
                if fm.fileExists(atPath: destinationURL.path) {
                    try fm.removeItem(at: destinationURL)
                }
                
                try fm.copyItem(at: location, to: destinationURL)
                
                main {
                    self.fileURL = destinationURL
                    
                    Task {
                        await self.fetchMetadata(destinationURL)
                        self.loadAndCheckImage()
                    }
                }
            } catch {
                print("Error during file copy: \(error.localizedDescription)")
            }
        }
        .resume()
    }
    
    private func loadAndCheckImage() {
        let processor = SensitivityAnalyzer()
        
        guard let fileURL else {
            return
        }
        
        Task {
            await processor.checkImage(fileURL) { blur in
                self.isSensitive = blur
            }
        }
    }
    
    func fetchMetadata(_ fileURL: URL) async {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("File not found at URL: \(fileURL)")
            return
        }
        
        do {
            let keys: Set<URLResourceKey> = [
                .nameKey,
                .localizedNameKey,
                .localizedTypeDescriptionKey,
                .creationDateKey,
                .contentModificationDateKey,
                .attributeModificationDateKey,
                .contentAccessDateKey,
                .isHiddenKey,
                .isReadableKey,
                .isWritableKey,
                .isExecutableKey,
                .fileSizeKey,
                .fileAllocatedSizeKey,
                .totalFileSizeKey,
                .totalFileAllocatedSizeKey,
                .preferredIOBlockSizeKey,
                .typeIdentifierKey,
                .contentTypeKey,
                .generationIdentifierKey,
                .documentIdentifierKey,
                .fileIdentifierKey,
                .isDirectoryKey,
                .isRegularFileKey,
                .isSymbolicLinkKey,
                .isSystemImmutableKey,
                .isUserImmutableKey,
                .isExcludedFromBackupKey,
                .isAliasFileKey,
                .isPackageKey,
                .linkCountKey,
                .labelColorKey,
                .labelNumberKey
                // .tagNamesKey
            ]
            
            let resourceValues = try fileURL.resourceValues(forKeys: keys)
            let allTags = resourceValues.allValues
            
            metadata = allTags
        } catch {
            print("Failed to fetch resource values: \(error)")
        }
    }
}
