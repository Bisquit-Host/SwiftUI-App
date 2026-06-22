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
            
            guard let fileURL = await downloadRemoteFile(url, name: name) else {
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

private func downloadRemoteFile(_ urlString: String, name: String) async -> URL? {
    guard let url = URL(string: urlString) else {
        Logger().error("Invalid URL: \(urlString)")
        return nil
    }
    
    let destinationURL = URL.temporaryDirectory.appending(path: name)
    
    do {
        let (location, _) = try await URLSession.shared.download(from: url)
        
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            try FileManager.default.removeItem(at: destinationURL)
        }
        
        try FileManager.default.copyItem(at: location, to: destinationURL)
        return destinationURL
    } catch {
        Logger().error("Error during file download: \(error)")
        return nil
    }
}
