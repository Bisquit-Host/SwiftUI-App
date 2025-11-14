import Foundation
import PteroNet

@Observable
final class QuickLookViewVM {
    var fileURL: URL? = nil
    
    func fetchDownloadUrl(_ id: String?, file: String, at root: String?) async {
        guard let id, let root else {
            return
        }
        
        do {
            let url = try await fileDownloadAPI(id, path: root + "/" + file)
            downloadFile(url, name: file)
        } catch {
            SystemAlert.error(error)
        }
    }
    
    private func downloadFile(_ urlString: String, name: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let tempDirURL = FileManager.default.temporaryDirectory
        let destinationURL = tempDirURL.appendingPathComponent(name)
        
        URLSession.shared.downloadTask(with: url) { location, _, error in
            guard let location, error == nil else {
                return
            }
            
            do {
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }
                
                try FileManager.default.copyItem(at: location, to: destinationURL)
                
                Task { @MainActor in
                    self.fileURL = destinationURL
                }
            } catch {
                print("Error during file copy:", error.localizedDescription)
            }
        }
        .resume()
    }
}
