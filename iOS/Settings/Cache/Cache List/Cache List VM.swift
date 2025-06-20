import ScrechKit
import Kingfisher

struct CachedImage: Identifiable {
    let id = UUID()
    let image: UIImage
    let size: String
}

@Observable
final class CacheListVM {
    private(set) var images = [CachedImage]()
    
    func retrieveAllCachedImages() {
        images = []
        
        let cachePath = ImageCache.default.diskStorage
        
        retrieveImages(cachePath.directoryURL.path)
    }
    
    private func retrieveImages(_ path: String) {
        let fm = FileManager.default
        
        guard
            let files = try? fm.contentsOfDirectory(atPath: path)
        else {
            return
        }
        
        for file in files {
            let filePath = path + "/" + file
            var isDir: ObjCBool = false
            
            guard fm.fileExists(atPath: filePath, isDirectory: &isDir) else {
                return
            }
            
            guard !isDir.boolValue else {
                retrieveImages(filePath)
                return
            }
            
            guard
                let imageData = try? Data(contentsOf: URL(fileURLWithPath: filePath)),
                let image = UIImage(data: imageData)
            else {
                return
            }
            
            let size = formatBytes(imageData.count)
            
            images.append(.init(
                image: image,
                size: size
            ))
        }
    }
}
