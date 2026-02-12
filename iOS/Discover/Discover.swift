import SwiftUI
import MusicKit
import OSLog
import SafariCover
import MailCover

struct Discover: View {
    @State private var showMailCover = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                DiscoverCard("https://status.bisquit.host/status/bisquithost") {
                    DiscoverCardLabel("Status", subtitle: "System", image: .status)
                }
                
                Button {
                    openSafari("https://t.me/bisquit_host_chat")
                } label: {
                    DiscoverCardLabel("Telegram", subtitle: "Channel", image: .telegram)
                }
                
                Button {
                    openSafari("https://discord.com/invite/kerMT2r9rz")
                } label: {
                    DiscoverCardLabel("Discord", subtitle: "Guild", image: .discord)
                }
                
                Button {
                    openSafari("https://my.bisquit.host/discord.php")
                } label: {
                    DiscoverCardLabel("Client role", subtitle: "Guild", image: .discord)
                }
                
                Button {
                    openSafari(Endpoint.testflight)
                } label: {
                    DiscoverCardLabel("TestFlight", subtitle: "Beta Testing", image: .testFlight)
                }
                
                Button {
                    openSafari(Endpoint.moreAppsTopScrech)
                } label: {
                    DiscoverCardLabel("More apps", subtitle: "By Bisquit.Host", image: .logo)
                }
                
                DiscoverMusicMenu()
                
                Button {
                    showMailCover = true
                } label: {
                    DiscoverCardLabel("Feedback", subtitle: "Feature requests", image: .mail)
                }
                
                DiscoverCard(Endpoint.bisquitWiki) {
                    DiscoverCardLabel("Wiki", subtitle: "How to...?", image: .wiki)
                }
                
                DiscoverCard(Endpoint.bisquitPter) {
                    DiscoverCardLabel("Panel", subtitle: "Web", image: .safari)
                }
                
                DiscoverDocuments()
            }
            .padding([.vertical, .bottom], 20)
        }
        .scrollIndicators(.never)
        .scenePadding(.horizontal)
        .ignoresSafeArea()
        .foregroundStyle(.foreground)
        .ornamentDismissButton()
#if os(visionOS)
        .buttonBorderShape(.roundedRectangle(radius: 27))
        .buttonStyle(.plain)
#endif
        .mailCover(
            $showMailCover,
            message: "Hello there! \n",
            subject: "Bisquit.Host Feedback",
            recipients: ["topscrech@icloud.com"]
        )
    }
}

private struct DiscoverMusicMenu: View {
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
    
    @MainActor
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

private enum DiscoverSong: CaseIterable {
    case vibratoKombayn, vadimKupilIPv6, bisquitus
    
    var title: String {
        switch self {
        case .vibratoKombayn: "Вибратор-комбайн"
        case .vadimKupilIPv6: "Вадим купил IPv6"
        case .bisquitus: "Bisquitus"
        }
    }
    
    var id: MusicItemID {
        switch self {
        case .vibratoKombayn: MusicItemID("1819051074")
        case .vadimKupilIPv6: MusicItemID("1770029033")
        case .bisquitus: MusicItemID("1764417433")
        }
    }
}

#Preview {
    NavigationStack {
        Discover()
        //            .background {
        //                Image(.darkBackgroundInfo)
        //                    .resizable()
        //                    .ignoresSafeArea()
        //                    .blur(radius: 55, opaque: true)
        //            }
        //            .scrollContentBackground(.hidden)
    }
    .darkSchemePreferred()
}
