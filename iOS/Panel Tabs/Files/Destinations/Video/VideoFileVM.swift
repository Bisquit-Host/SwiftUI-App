import SwiftUI
import Calagopus
import OSLog

@Observable
final class VideoFileVM {
    private let id, root, name: String
    
    init(_ id: String, root: String, name: String) {
        self.id = id
        self.root = root
        self.name = name
    }
    
    var isSensitive = false
    var localVideoURL: URL?
    
    func fetchVideoURL(_ name: String, root: String) async {
        do {
            let url = try await CalagopusNet.client().fileDownloadURL(server: id, path: root + "/" + name)
            
            guard let fileURL = await VideoFileShareCache.localFile(from: url, name: name) else {
                return
            }

            await loadAndCheckVideo(fileURL)
        } catch {
            SystemAlert.error(error)
        }
    }
    
    private func loadAndCheckVideo(_ fileURL: URL) async {
#if !os(watchOS) && !os(tvOS)
        await SensitivityAnalyzer().checkVideo(fileURL) { blur in
            self.isSensitive = blur

            withAnimation {
                self.localVideoURL = fileURL
            }
        }
#else
        localVideoURL = fileURL
#endif
    }
}

private enum VideoFileShareCache {
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
