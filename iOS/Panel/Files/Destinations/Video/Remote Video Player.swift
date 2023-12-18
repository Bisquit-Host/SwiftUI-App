import SwiftUI
import AVKit

struct UIKitVideoPlayerView: View {
    @StateObject private var videoPlayerVM = VideoPlayerViewModel.default
    
    var body: some View {
        UIVideoPlayer(player: videoPlayerVM.player)
            .onAppear {
                setAudioSessionCategory(to: .playback)
                videoPlayerVM.player.play()
            }
            .onDisappear {
                videoPlayerVM.player.pause()
                setAudioSessionCategory(to: .ambient)
            }
    }
    
    func setAudioSessionCategory(to value: AVAudioSession.Category) {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(value)
        } catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
    }
}

#Preview {
    UIKitVideoPlayerView()
}

struct UIVideoPlayer: UIViewControllerRepresentable {
    let player: AVPlayer
    
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

import Combine
import AVKit

final class VideoPlayerViewModel: ObservableObject {
    @Published var selectedResolution: Resolution
    @Published private var shouldLowerResolution = false
    
    let player = AVPlayer()
    private let video: Video
    private var subscriptions: Set<AnyCancellable> = []
    private var timeObserverToken: Any?
    
    var name: String { video.name }
    var namePlusResolution: String { video.name + " at " + selectedResolution.displayValue }
    
    init(video: Video, initialResolution: Resolution) {
        self.video = video
        self.selectedResolution = initialResolution
        
        $shouldLowerResolution
            .dropFirst()
            .filter {
                $0 == true
            }
            .sink { [weak self] _ in
                guard let self = self else {
                    return
                }
                self.lowerResolutionIfPossible()
            }
            .store(in: &subscriptions)
        
        $selectedResolution
            .sink { [weak self] resolution in
                guard let self = self else { return }
                self.replaceItem(with: resolution)
                self.setObserver()
            }
            .store(in: &subscriptions)
    }
    
    deinit {
        if let timeObserverToken = timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
        }
    }
    
    private func setObserver() {
        if let timeObserverToken = timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
        }
        
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 600), queue: DispatchQueue.main) { [weak self] time in
            guard let self = self,
                  let currentItem = self.player.currentItem else {
                return
            }
            
            guard currentItem.isPlaybackBufferFull == false else {
                self.shouldLowerResolution = false
                return
            }
            
            if currentItem.status == AVPlayerItem.Status.readyToPlay {
                self.shouldLowerResolution = (!currentItem.isPlaybackLikelyToKeepUp && !currentItem.isPlaybackBufferEmpty)
            }
        }
    }
    
    private func lowerResolutionIfPossible() {
        guard let newResolution = Resolution(rawValue: selectedResolution.rawValue - 1) else {
            return
        }
        
        selectedResolution = newResolution
    }
    
    private func replaceItem(with newResolution: Resolution) {
        guard let stream = self.video.streams.first(where: { $0.resolution == newResolution }) else {
            return
        }
        
        let currentTime: CMTime
        if let currentItem = player.currentItem {
            currentTime = currentItem.currentTime()
        } else {
            currentTime = .zero
        }
        
        player.replaceCurrentItem(with: AVPlayerItem(url: stream.streamURL))
        player.seek(to: currentTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }
}

extension VideoPlayerViewModel {
    static var `default`: Self {
        .init(video: Video(name: "Promo Video", streams: [
            Stream(resolution: .p360, streamURL: URL(string: "https://d142uv38695ylm.cloudfront.net/videos/promo/allesneu.land-promo-trailer-360p.m3u8")!),
            Stream(resolution: .p540, streamURL: URL(string: "https://d142uv38695ylm.cloudfront.net/videos/promo/allesneu.land-promo-trailer-540p.m3u8")!),
            Stream(resolution: .p720, streamURL: URL(string: "https://d142uv38695ylm.cloudfront.net/videos/promo/allesneu.land-promo-trailer-720p.m3u8")!),
            Stream(resolution: .p1080, streamURL: URL(string: "https://d142uv38695ylm.cloudfront.net/videos/promo/allesneu.land-promo-trailer-1080p.m3u8")!)
        ]),
              initialResolution: .p540)
    }
}

import Foundation
import Network

struct Video {
    let name: String
    let streams: [Stream]
}

struct Stream {
    let resolution: Resolution
    let streamURL: URL
}

enum Resolution: Int, Identifiable, Comparable, CaseIterable {
    case p360 = 0
    case p540
    case p720
    case p1080
    
    var id: Int {
        rawValue
    }
    
    var displayValue: String {
        switch self {
        case .p360: "360p"
        case .p540: "540p"
        case .p720: "720p"
        case .p1080: "1080p"
        }
    }
    
    static func ==(lhs: Resolution, rhs: Resolution) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
    
    static func <(lhs: Resolution, rhs: Resolution) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

//import ScrechKit
//import AVKit
//
//final class PlayerUIView: AVPlayerViewController {
//    var playerURL: URL? {
//        didSet {
//            if let url = playerURL {
//                player = AVPlayer(url: url)
//            }
//        }
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        self.player?.play()
//    }
//    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        self.player?.pause()
//    }
//}
//
//struct RemoteVideoPlayer: UIViewControllerRepresentable {
//    private let url: URL
//    
//    init(_ url: URL) {
//        self.url = url
//    }
//    
//    func makeUIViewController(context: Context) -> PlayerUIView {
//        let controller = PlayerUIView()
//        var player = controller.player
//        
//        player = AVPlayer(url: url)
//        player?.play()
//        
//        return controller
//    }
//    
//    func updateUIViewController(_ uiViewController: PlayerUIView, context: Context) {
//        uiViewController.playerURL = url
//    }
//}
//
//#Preview {
//    RemoteVideoPlayer(
//        URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
//    )
//}
