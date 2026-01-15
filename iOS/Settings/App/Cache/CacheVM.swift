import ScrechKit
import Kingfisher
import os

@Observable
final class CacheVM {
    private(set) var cacheSize = ""
    
    private let cache: ImageCache = .default
    
    func clearAll() {
        cache.clearMemoryCache()
        
        cache.clearDiskCache {
            Task { @MainActor in
                self.calculateCacheSize()
            }
        }
    }
    
    func updateExpirationTime(to time: StorageExpiration) {
        cache.diskStorage.config.expiration = time
        
        print(cache.diskStorage.config.expiration)
    }
    
    func updateLimit(_ limit: UInt) {
        cache.diskStorage.config.sizeLimit = limit
        cache.memoryStorage.config.totalCostLimit = Int(limit)
        
        SystemAlert.done("Cache life time updated")
    }
    
    func calculateCacheSize() {
        cache.calculateDiskStorageSize { result in
            Task { @MainActor in
                switch result {
                case .success(let size):
                    let formattedSize = formatBytes(size)
                    self.cacheSize = formattedSize
                    
                case .failure(let error):
                    Logger().error("\(error)")
                    self.cacheSize = "Empty"
                }
            }
        }
    }
}
