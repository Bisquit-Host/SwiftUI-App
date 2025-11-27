import Foundation
import PteroNet

@Observable
final class AudioPlayerVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var audioURL: URL? = nil
    
    func fetchDownloadURL(_ file: String, at path: String) async {
        do {
            let url = try await fileDownloadAPI(id, path: path + "/" + file)
            await downloadFile(url, name: file)
        } catch {
            SystemAlert.error(error)
        }
    }
    
    private func downloadFile(_ urlString: String, name: String) async {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
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
            
            audioURL = destinationURL
        } catch {
            print("Error during file copy:", error.localizedDescription)
        }
    }
}
