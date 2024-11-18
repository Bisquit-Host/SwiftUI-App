import ScrechKit
import PteroNet

@Observable
final class QuickLookFileVM {
    var fileURL: URL? = nil
    var isSensitive = false
    
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    private func loadAndCheckImage() {
        let processor = SensitivityAnalyzer()
        
        guard let fileURL else {
            return
        }
        
        Task {
            await processor.checkImage(fileURL) { blur in
                self.isSensitive = blur
            }
        }
    }
    
    func downloadFile(_ file: String, root: String) {
        fileDownloadAPI(id, path: root + "/\(file)") { result in
            switch result {
            case .success(let model):
                if let model = model?.attributes.url {
                    self.downloadVideo(model, name: file)
                }
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
    
    private func downloadVideo(_ urlString: String, name: String) {
        let fm = FileManager.default
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let tempDirectoryURL = fm.temporaryDirectory
        let destinationURL = tempDirectoryURL.appendingPathComponent(name)
        
        URLSession.shared.downloadTask(with: url) { location, response, error in
            let fm = FileManager.default
            
            guard let location, error == nil else {
                print("Download error: \(error?.localizedDescription ?? "No error description available")")
                return
            }
            
            do {
                if fm.fileExists(atPath: destinationURL.path) {
                    try fm.removeItem(at: destinationURL)
                }
                
                try fm.copyItem(at: location, to: destinationURL)
                
                main {
                    self.fileURL = destinationURL
                    
                    Task {
                        self.loadAndCheckImage()
                    }
                }
            } catch {
                print("Error during file copy: \(error.localizedDescription)")
            }
        }
        .resume()
    }
    
}
