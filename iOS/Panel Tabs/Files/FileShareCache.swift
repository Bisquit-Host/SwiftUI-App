import Foundation
import OSLog

enum FileShareCache {
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
