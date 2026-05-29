import SwiftUI
import MusicKit
import OSLog

struct DiscoverMusicMenu: View {
    private static let logger = Logger(subsystem: "host.bisquit.Bisquit-host", category: "DiscoverMusicMenu")
    
    var body: some View {
        Menu {
            ForEach(DiscoverSong.allCases, id: \.self) { song in
                Button(song.title) {
                    play(song)
                }
            }
        } label: {
            DiscoverCardLabel("Music", subtitle: "Play a song", image: .logo)
        }
    }
    
    private func play(_ song: DiscoverSong) {
        let songID = song.id
        
        Task { @MainActor in
            await DiscoverMusicMenu.playSong(id: songID)
        }
    }
    
    private static func playSong(id: MusicItemID) async {
        let status = await MusicAuthorization.request()
        
        guard status == .authorized else {
            logger.error("Music authorization denied: \(String(describing: status))")
            return
        }
        
        do {
            let request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: id)
            let response = try await request.response()
            
            guard let song = response.items.first else {
                logger.error("Song not found for id: \(id)")
                return
            }
            
            let player = SystemMusicPlayer.shared
            player.queue = [song]
            
            try await player.play()
        } catch {
            logger.error("Music play failed: \(error)")
        }
    }
}
