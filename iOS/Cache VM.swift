import ScrechKit
import Kingfisher

@Observable
final class CacheVM {
    var cacheSize = ""
    
    private let cache: ImageCache = .default
    
    func clearAll() {
        cache.clearMemoryCache()
        
        cache.clearDiskCache {
            self.calculateCacheSize()
        }
    }
    
    func updateExpirationTime(to time: StorageExpiration) {
        cache.diskStorage.config.expiration = time
        
        print(cache.diskStorage.config.expiration)
    }
    
    func updateLimit(to limit: UInt) {
        cache.diskStorage.config.sizeLimit = limit
        cache.memoryStorage.config.totalCostLimit = Int(limit)
        
        print(cache.diskStorage.config.sizeLimit)
    }
    
    func calculateCacheSize() {
        cache.calculateDiskStorageSize { [weak self] result in
            switch result {
            case .success(let size):
                let formattedSize = formatBytes(Double(size))
                self?.cacheSize = formattedSize
                
            case .failure(let error):
                print(error.localizedDescription)
                
                self?.cacheSize = "Empty"
            }
        }
    }
}
