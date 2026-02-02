import Foundation
import Kingfisher

struct Prefetcher {
    static func prefetchImages(_ urls: [URL]) {
        let uniqueURLs = Array(Set(urls))
        ImagePrefetcher(urls: uniqueURLs).start()
    }
}
