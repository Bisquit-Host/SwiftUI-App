import SwiftUI
import SafariCover
import MailCover

struct Discover: View {
    @Environment(\.dismiss) private var dismiss
    
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
    // TestFlight
    //    ]
    
    @State private var sheetConfigurations = false
    @State private var showMailCover = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                Button {
                    sheetConfigurations = true
                } label: {
                    DiscoverCardLayout(
                        .init("Configurations", subtitle: "Available to buy", image: .server)
                    )
                }
                
                DiscoverCard("https://my.bisquit.host/login") {
                    DiscoverCardLayout(
                        .init("Support", subtitle: "Me Potato, me HELP", image: .support)
                    )
                }
                
                DiscoverCard("https://status.bisquit.host/status/bisquithost") {
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
                    openSafari("https://testflight.apple.com/join/mkaX3AO1")
                } label: {
                    DiscoverCardLayout(
                        .init("TestFlight", subtitle: "Beta Testing", image: .testFlight)
                    )
                }
                
                Button {
                    openSafari("https://apps.apple.com/au/developer/sergei-saliukov/id1639409936")
                } label: {
                    DiscoverCardLayout(
                        .init("More apps", subtitle: "By Bisquit.Host", image: .logo)
                    )
                }
                
                Button {
                    showMailCover = true
                } label: {
                    DiscoverCardLayout(
                        .init("Feedback", subtitle: "Feature requests", image: .mail)
                    )
                }
                
                DiscoverCard("https://wiki.bisquit.host") {
                    DiscoverCardLayout(
                        .init("Wiki", subtitle: "How to...?", image: .wiki)
                    )
                }
                
                DiscoverCard("https://mgr.bisquit.host") {
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
                
                DiscoverCard("https://bisquit.host/policy.pdf") {
                    DiscoverCardLayout(
                        .init("Privacy", subtitle: "Policy", image: .docBlue)
                    )
                }
                
                DiscoverCard("https://bisquit.host/terms.pdf") {
                    DiscoverCardLayout(
                        .init("Terms", subtitle: "Document", image: .docYellow)
                    )
                }
            }
            .padding(.vertical)
        }
        .ignoresSafeArea()
        .foregroundStyle(.foreground)
        .ornamentDismissButton()
        .sheet($sheetConfigurations) {
            PlanViewParent()
        }
#if os(visionOS)
        .buttonBorderShape(.roundedRectangle(radius: 27))
        .buttonStyle(.plain)
        .ornamentDismissButton()
#else
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                DismissButton {
                    dismiss()
                }
            }
            
            ToolbarSpacer(placement: .bottomBar)
        }
#endif
        .mailCover(
            $showMailCover,
            message: "Hello there! \n",
            subject: "Bisquit.Host Feedback",
            recipients: ["topscrech@icloud.com"]
        )
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
}
