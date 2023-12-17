import ScrechKit
import AVKit

final class PlayerUIView: AVPlayerViewController {
    var playerURL: URL? {
        didSet {
            if let url = playerURL {
                player = AVPlayer(url: url)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.player?.play()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.player?.pause()
    }
}

struct RemoteVideoPlayer: UIViewControllerRepresentable {
    private let url: URL
    
    init(_ url: URL) {
        self.url = url
    }
    
    func makeUIViewController(context: Context) -> PlayerUIView {
        let controller = PlayerUIView()
        var player = controller.player
        
        player = AVPlayer(url: url)
        player?.play()
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: PlayerUIView, context: Context) {
        uiViewController.playerURL = url
    }
}

#Preview {
    RemoteVideoPlayer(
        URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
    )
}
