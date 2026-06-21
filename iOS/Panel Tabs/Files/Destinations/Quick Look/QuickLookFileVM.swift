import ScrechKit
import Calagopus

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
            guard let destinationURL = await downloadFile(url, name: file) else {
                return
            }

            await loadAndCheckImage(destinationURL)
            await fetchMetadata(destinationURL)
            fileURL = destinationURL
        } catch {
            SystemAlert.error(error)
        }
    }
    
    private func loadAndCheckImage(_ url: URL?) async {
        guard let url else { return }
        
        await SensitivityAnalyzer().checkImage(url) { blur in
            self.isSensitive = blur
            
            Logger().info("\(blur ? "🍆 Sensetive content found" : "Content is safe")")
        }
    }
    
    func fetchMetadata(_ fileURL: URL) async {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            Logger().error("File not found at URL: \(fileURL)")
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
            Logger().error("Failed to fetch resource values: \(error)")
        }
    }
}
