import Foundation
import Calagopus
import OSLog

@Observable
final class QuickLookVM {
    var fileURL: URL? = nil
    
    func fetchDownloadURL(_ id: String, file: String, at path: String) async {
        do {
            let url = try await CalagopusNet.client().fileDownloadURL(server: id, path: path + "/" + file)
            fileURL = await downloadRemoteFile(url, name: file)
        } catch {
            SystemAlert.error(error)
        }
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
