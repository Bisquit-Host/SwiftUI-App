import SwiftUI
import Kingfisher

@Observable
final class CacheListVM {
    var images = [UIImage]()
    
    func retrieveAllCachedImages() {
        images = []
        
        let cache = ImageCache.default
        
        // Get the cache path
        let cachePath = cache.diskStorage.directoryURL.path
        
        retrieveImages(cachePath)
    }
    
    func retrieveImages(_ path: String) {
        let fm = FileManager.default
        
        if let files = try? fm.contentsOfDirectory(atPath: path) {
            print(files.count)
            
            for file in files {
                let filePath = path + "/" + file
                var isDir: ObjCBool = false
                
                if fm.fileExists(atPath: filePath, isDirectory: &isDir) {
                    if isDir.boolValue {
                        retrieveImages(filePath)
                    } else {
                        if let imageData = try? Data(contentsOf: URL(fileURLWithPath: filePath)),
                           let image = UIImage(data: imageData) {
                            images.append(image)
                        }
                    }
                }
            }
        }
    }
}
