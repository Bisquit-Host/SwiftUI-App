import Foundation
import Kingfisher

func prefetchImages(_ urls: [URL]) {
    let uniqueURLs = Array(Set(urls))
    
    let prefetcher = ImagePrefetcher(urls: uniqueURLs)
    prefetcher.start()
}
