import Foundation
import PteroNet

@Observable
final class QuickLookViewVM {
    var fileURL: URL? = nil
    
    func fetchDownloadURL(_ id: String?, file: String, at root: String?) async {
        guard let id, let root else { return }
        
        do {
            let url = try await fileDownloadAPI(id, path: root + "/" + file)
            await downloadFile(url, name: file)
        } catch {
            SystemAlert.error(error)
        }
    }
    
    private func downloadFile(_ urlString: String, name: String) async {
        guard let url = URL(string: urlString) else {
            Logger().error("Invalid URL")
            return
        }
        
        let tempDirURL = FileManager.default.temporaryDirectory
        let destinationURL = tempDirURL.appendingPathComponent(name)
        
        do {
            let (location, _) = try await URLSession.shared.download(from: url)
            
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            
            try FileManager.default.copyItem(at: location, to: destinationURL)
            fileURL = destinationURL
        } catch {
            print("Error during file copy:", error)
        }
    }
}
