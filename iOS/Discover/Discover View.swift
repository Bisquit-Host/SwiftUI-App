import SwiftUI
import SafariCover
import MailCover

struct Discover: View {
    //    private let links: [DiscoverModel] = [
    //        .init("Configurations", subtitle: "Available to buy", image: .server),
    //        .init("Support", subtitle: "Me Potato, me HELP", image: .support),
    //        .init("Status", subtitle: "System", image: .status),
    //        .init("Telegram", subtitle: "Channel", image: .telegram),
    //        .init("Discord", subtitle: "Guild", image: .discord),
    //        .init("Client role", subtitle: "Discord", image: .discord),
    //        .init("More apps", subtitle: "By Bisquit.Host", image: .logo),
    //        .init("Wiki", subtitle: "How to...?", image: .wiki),
    //        .init("Panel", subtitle: "Web", image: .safari),
    //        .init("Maps", subtitle: "Best places", image: .maps),
    //        .init("Privacy Policy", subtitle: "Document", image: .docBlue),
    //        .init("Offer", subtitle: "Document", image: .docYellow)
    //    ]
    
    private let columns = Array(
        repeating: GridItem(.fixed(UIScreen.main.bounds.width * 0.45 + 2), spacing: 16),
        count: 2
    )
    
    @State private var sheetConfigurations = false
    @State private var showMailCover = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 16) {
                Button {
                    sheetConfigurations = true
                } label: {
                    DiscoverCardLayout(
                        .init("Configurations", subtitle: "Available to buy", image: .server)
                    )
                }
                
                Button {
                    openSafari("https://my.bisquit.host/login")
                } label: {
                    DiscoverCardLayout(
                        .init("Support", subtitle: "Me Potato, me HELP", image: .support)
                    )
                }
                
                Button {
                    openSafari("https://status.bisquit.host/status/bisquithost")
                } label: {
                    DiscoverCardLayout(
                        .init("Status", subtitle: "System", image: .status)
                    )
                }
                
                Button {
                    openSafari("https://t.me/bisquit_host_chat")
                } label: {
                    DiscoverCardLayout(
                        .init("Telegram", subtitle: "Channel", image: .telegram)
                    )
                }
                
                Button {
                    openSafari("https://discord.com/invite/kerMT2r9rz")
                } label: {
                    DiscoverCardLayout(
                        .init("Discord", subtitle: "Guild", image: .discord)
                    )
                }
                
                Button {
                    openSafari("https://my.bisquit.host/discord.php")
                } label: {
                    DiscoverCardLayout(
                        .init("Client role", subtitle: "Guild", image: .discord)
                    )
                }
                
                Button {
                    showMailCover = true
                } label: {
                    DiscoverCardLayout(
                        .init("Feedback", subtitle: "Feature requests", image: .mail)
                    )
                }
                
                Button {
                    openSafari("https://apps.apple.com/au/developer/sergei-saliukov/id1639409936")
                } label: {
                    DiscoverCardLayout(
                        .init("More apps", subtitle: "By Bisquit.Host", image: .defaultIcon)
                    )
                }
                
                Button {
                    openSafari("https://wiki.bisquit.host")
                } label: {
                    DiscoverCardLayout(
                        .init("Wiki", subtitle: "How to...?", image: .wiki)
                    )
                }
                
                Button {
                    openSafari("https://mgr.bisquit.host")
                } label: {
                    DiscoverCardLayout(
                        .init("Panel", subtitle: "Web", image: .safari)
                    )
                }
                
                NavigationLink {
                    MapView()
                } label: {
                    DiscoverCardLayout(
                        .init("Maps", subtitle: "Best places", image: .maps)
                    )
                }
                
                Button {
                    openSafari("https://bisquit.host/policy.pdf")
                } label: {
                    DiscoverCardLayout(
                        .init("Privacy", subtitle: "Policy", image: .docBlue)
                    )
                }
                
                Button {
                    openSafari("https://bisquit.host/terms.pdf")
                } label: {
                    DiscoverCardLayout(
                        .init("Terms", subtitle: "Document", image: .docYellow)
                    )
                }
            }
            .padding(.vertical)
        }
        .ignoresSafeArea()
        .transparentList()
        .foregroundStyle(.foreground)
        .ornamentDismissButton()
        .mailCover(
            $showMailCover,
            message: "Hello there! \n",
            subject: "Bisquit.Host Feedback",
            recipients: ["topscrech@icloud.com"]
        )
        .sheet($sheetConfigurations) {
            BrowserParent()
        }
    }
}

#Preview {
    NavigationView {
        Discover()
        //            .background {
        //                Image(.darkBackgroundInfo)
        //                    .resizable()
        //                    .ignoresSafeArea()
        //                    .blur(radius: 55, opaque: true)
        //            }
        //            .scrollContentBackground(.hidden)
    }
}
