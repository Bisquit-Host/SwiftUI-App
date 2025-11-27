import SwiftUI
import PteroNet

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
            let url = try await fileDownloadAPI(id, path: root + "/" + name)
            self.saveVideo(url)
        } catch {
            SystemAlert.error(error)
        }
    }
    
    private func saveVideo(_ urlString: String) {
        let fm = FileManager.default
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let tempDirURL = fm.temporaryDirectory
        let fileURL = tempDirURL.appendingPathComponent(name)
        
        URLSession.shared.downloadTask(with: url) { location, response, error in
            let fm = FileManager.default
            
            guard let location, error == nil else {
                print("Download error:", error?.localizedDescription ?? "Unknown error")
                return
            }
            
            do {
                if fm.fileExists(atPath: fileURL.path) {
                    try fm.removeItem(at: fileURL)
                }
                
                try fm.moveItem(at: location, to: fileURL)
                
                Task { @MainActor in
#if !os(watchOS) && !os(tvOS)
                    let processor = SensitivityAnalyzer()
                    
                    await processor.checkVideo(fileURL) { blur in
                        self.isSensitive = blur
                        
                        withAnimation {
                            self.localVideoURL = fileURL
                        }
                    }
#else
                    self.localVideoURL = fileURL
#endif
                }
            } catch {
                print("Error during file move:" + error.localizedDescription)
            }
        }
        .resume()
    }
    
}
