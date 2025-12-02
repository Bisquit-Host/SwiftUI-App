import SwiftUI
import AVKit

struct VideoPlayerView: View {
    private var videoPlayerVM: VideoPlayerVM
    
    init(_ url: URL) {
        videoPlayerVM = VideoPlayerVM(url: url)
    }
    
    var body: some View {
        UIVideoPlayer(videoPlayerVM.player)
            .task {
                setAudioSessionCategory(to: .playback)
                videoPlayerVM.player.play()
            }
            .onDisappear {
                videoPlayerVM.player.pause()
                setAudioSessionCategory(to: .ambient)
            }
    }
    
    private func setAudioSessionCategory(to value: AVAudioSession.Category) {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(value)
        } catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed")
        }
    }
}

#Preview {
    VideoPlayerView(
        URL(string: "https://d142uv38695ylm.cloudfront.net/videos/promo/allesneu.land-promo-trailer-360p.m3u8")!
    )
    .darkSchemePreferred()
}
