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
    var isLoaded = false
    
    private let fm = FileManager.default
    
    private var cacheDirectory: URL {
        let dir = fm.temporaryDirectory.appendingPathComponent("FileCache", isDirectory: true)
        
        if !fm.fileExists(atPath: dir.path) {
            try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        
        return dir
    }
    
    func getFileUrl(_ file: String, at root: String) {
        let cachedUrl = cacheDirectory.appendingPathComponent(file)
        
        if fm.fileExists(atPath: cachedUrl.path) {
            fileUrl = cachedUrl
            
            Task {
                checkFile()
            }
        }
        
        fileDownloadAPI(id, path: root + "/" + file) { result in
            switch result {
            case .success(let model):
                if let url = model?.attributes.url {
                    self.downloadFile(url, name: file)
                }
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
    
    private func downloadFile(_ urlString: String, name: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL string: \(urlString)")
            return
        }
        
        let destinationUrl = cacheDirectory.appendingPathComponent(name)
        
        URLSession.shared.downloadTask(with: url) { location, response, error in
            guard let location, error == nil else {
                print("Download error: \(error?.localizedDescription ?? "No error description available")")
                return
            }
            
            do {
                if self.fm.fileExists(atPath: destinationUrl.path) {
                    try self.fm.removeItem(at: destinationUrl)
                }
                
                try self.fm.copyItem(at: location, to: destinationUrl)
                
                main {
                    self.fileUrl = destinationUrl
                    self.checkFile()
                }
            } catch {
                print("Error during file copy: \(error.localizedDescription)")
            }
        }
        .resume()
    }
    
    private func checkFile() {
        let analyzer = SensitivityAnalyzer()
        
        guard let fileUrl else {
            return
        }
        
        Task {
            await analyzer.checkImage(fileUrl) { blur in
                self.isSensitive = blur
            }
            
            self.isLoaded = true
        }
    }
}
