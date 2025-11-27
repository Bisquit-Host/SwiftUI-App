import ScrechKit
import PteroNet

@Observable
final class AudioPlayerVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var audioURL: URL? = nil
    
    func downloadFile(_ file: String, at path: String) async {
        do {
            let url = try await fileDownloadAPI(id, path: path + "/\(file)")
            self.downloadVideo(url, name: file)
        } catch {
            SystemAlert.error(error)
        }
    }
    
    private func downloadVideo(_ urlString: String, name: String) {
        let fm = FileManager.default
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
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
                    withAnimation {
                        self.audioURL = destinationURL
                    }
                }
            } catch {
                print("Error during file copy:", error.localizedDescription)
            }
        }
        .resume()
    }
}
