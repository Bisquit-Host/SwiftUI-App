import Foundation
import AVKit

final class VideoPlayerVM: ObservableObject {
    let player = AVPlayer()
    
    init(url: URL) {
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
    }
}
