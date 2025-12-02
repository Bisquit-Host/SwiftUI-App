import SwiftUI
import SafariCover
import MailCover

struct Discover: View {
    @State private var showMailCover = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
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
        .scenePadding(.horizontal)
        .ignoresSafeArea()
        .foregroundStyle(.foreground)
        .ornamentDismissButton()
#if os(visionOS)
        .buttonBorderShape(.roundedRectangle(radius: 27))
        .buttonStyle(.plain)
#else
        .toolbar {
            ToolbarSpacer(placement: .bottomBar)
            
            ToolbarItem(placement: .bottomBar) {
                DismissButton()
            }
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
    .darkSchemePreferred()
}
