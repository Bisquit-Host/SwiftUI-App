import ScrechKit
import PteroNet

@Observable
final class FilePreviewVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var fileUrl: URL? = nil
    var isSensitive = false
    
    func getFileUrl(_ file: String, at root: String) {
        fileDownloadAPI(id, path: root + "/" + file) { result in
            switch result {
            case .success(let model):
                if let model = model?.attributes.url {
                    self.downloadFile(model, name: file)
                }
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
    
    private func downloadFile(_ urlString: String, name: String) {
        let fm = FileManager.default
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let tempDirectoryUrl = fm.temporaryDirectory
        let destinationUrl = tempDirectoryUrl.appendingPathComponent(name)
        
        URLSession.shared.downloadTask(with: url) { location, response, error in
            guard let location, error == nil else {
                print("Download error: \(error?.localizedDescription ?? "No error description available")")
                return
            }
            
            do {
                if fm.fileExists(atPath: destinationUrl.path) {
                    try fm.removeItem(at: destinationUrl)
                }
                
                try fm.copyItem(at: location, to: destinationUrl)
                
                main {
                    self.fileUrl = destinationUrl
                    
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
    
    private func loadAndCheckImage() {
        let analyzer = SensitivityAnalyzer()
        
        guard let fileUrl else {
            return
        }
        
        Task {
            await analyzer.checkImage(fileUrl) { blur in
                self.isSensitive = blur
            }
        }
    }
}
