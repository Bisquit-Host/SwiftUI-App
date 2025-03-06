import Foundation
import Kingfisher

func prefetchImages(_ urls: [URL]) {
    let uniqueURLs = Array(Set(urls))
    
    ImagePrefetcher(urls: uniqueURLs).start()
}
