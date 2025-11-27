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
    
    func getFileURL(_ file: String, at root: String) async {
        do {
            let url = try await fileDownloadAPI(id, path: root + "/" + file)
            self.downloadFile(url, name: file)
        } catch {
            SystemAlert.error(error)
        }
    }
    
    private func downloadFile(_ urlString: String, name: String) {
        let fm = FileManager.default
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL:", urlString)
            return
        }
        
        let tempDirURL = fm.temporaryDirectory
        let destinationURL = tempDirURL.appendingPathComponent(name)
        
        URLSession.shared.downloadTask(with: url) { location, _, error in
            let fm = FileManager.default
            
            guard let location, error == nil else {
                print("Download error:", error?.localizedDescription ?? "Unknown error")
                return
            }
            
            do {
                if fm.fileExists(atPath: destinationURL.path) {
                    try fm.removeItem(at: destinationURL)
                }
                
                try fm.copyItem(at: location, to: destinationURL)
                
                Task { @MainActor in
                    await self.loadAndCheckImage(destinationURL)
                    await self.fetchMetadata(destinationURL)
                    self.fileURL = destinationURL
                }
            } catch {
                print("Error during file copy:", error.localizedDescription)
            }
        }
        .resume()
    }
    
    private func loadAndCheckImage(_ url: URL?) async {
        guard let url else { return }
        
        await SensitivityAnalyzer().checkImage(url) { blur in
            self.isSensitive = blur
            
            print(blur ? "🍆 Sensetive content found" : "Content is safe")
        }
    }
    
    func fetchMetadata(_ fileURL: URL) async {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("File not found at URL:", fileURL)
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
            print("Failed to fetch resource values:", error)
        }
    }
}
