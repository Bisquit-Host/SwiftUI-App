import SwiftUI
import AVKit

struct UIVideoPlayer: UIViewControllerRepresentable {
    private let player: AVPlayer
    
    init(_ player: AVPlayer) {
        self.player = player
    }
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let vc = AVPlayerViewController()
        
        vc.player = player
        vc.canStartPictureInPictureAutomaticallyFromInline = true
        
        return vc
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player = player
    }
}
