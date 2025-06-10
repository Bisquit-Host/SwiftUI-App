import ScrechKit
import Kingfisher

struct CachedImage: Identifiable {
    let id = UUID()
    let image: UIImage
    let size: String
}

@Observable
final class CacheListVM {
    var images = [CachedImage]()
    
    func retrieveAllCachedImages() {
        images = []
        
        let cache = ImageCache.default
        let cachePath = cache.diskStorage.directoryURL.path
        
        retrieveImages(cachePath)
    }
    
    private func retrieveImages(_ path: String) {
        let fm = FileManager.default
        
        guard let files = try? fm.contentsOfDirectory(atPath: path) else {
            return
        }
        
        for file in files {
            let filePath = path + "/" + file
            var isDir: ObjCBool = false
            
            guard fm.fileExists(atPath: filePath, isDirectory: &isDir) else {
                return
            }
            
            if isDir.boolValue {
                retrieveImages(filePath)
            } else {
                guard
                    let imageData = try? Data(contentsOf: URL(fileURLWithPath: filePath)),
                    let image = UIImage(data: imageData)
                else {
                    return
                }
                
                let sizeString = formatBytes(imageData.count)
                
                images.append(.init(
                    image: image,
                    size: sizeString
                ))
            }
        }
    }
}
