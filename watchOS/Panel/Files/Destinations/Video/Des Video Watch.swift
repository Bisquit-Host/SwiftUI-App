import SwiftUI
import AVFoundation
import AVKit

struct WatchVideoPlayer: View {
    private let url: URL
    
    init(_ url: URL) {
        self.url = url
    }
    
    var body: some View {
        let video = AVPlayer.init(url: url)
        
        VStack {
            VideoPlayer(player: video)
            
            Button("Mute") {
                video.isMuted.toggle()
            }
        }
    }
}

#Preview {
    WatchVideoPlayer(
        URL(string: "https://file-examples.com/storage/fea582e6406477bb69e8a67/2017/04/file_example_MP4_480_1_5MG.mp4")!
    )
}
