import SwiftUI
import SafariCover
import MailCover

struct Discover: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var sheetConfigurations = false
    @State private var showMailCover = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                Button {
                    sheetConfigurations = true
                } label: {
                    DiscoverCardLayout("Configurations", subtitle: "Available to buy", image: .server)
                }
                
                DiscoverCard("https://my.bisquit.host/login") {
                    DiscoverCardLayout("Support", subtitle: "Me Potato, me HELP", image: .support)
                }
                
                DiscoverCard("https://status.bisquit.host/status/bisquithost") {
                    DiscoverCardLayout("Status", subtitle: "System", image: .status)
                }
                
                Button {
                    openSafari("https://t.me/bisquit_host_chat")
                } label: {
                    DiscoverCardLayout("Telegram", subtitle: "Channel", image: .telegram)
                }
                
                Button {
                    openSafari("https://discord.com/invite/kerMT2r9rz")
                } label: {
                    DiscoverCardLayout("Discord", subtitle: "Guild", image: .discord)
                }
                
                Button {
                    openSafari("https://my.bisquit.host/discord.php")
                } label: {
                    DiscoverCardLayout("Client role", subtitle: "Guild", image: .discord)
                }
                
                Button {
                    openSafari("https://testflight.apple.com/join/mkaX3AO1")
                } label: {
                    DiscoverCardLayout("TestFlight", subtitle: "Beta Testing", image: .testFlight)
                }
                
                Button {
                    openSafari("https://apps.apple.com/au/developer/sergei-saliukov/id1639409936")
                } label: {
                    DiscoverCardLayout("More apps", subtitle: "By Bisquit.Host", image: .logo)
                }
                
                Button {
                    showMailCover = true
                } label: {
                    DiscoverCardLayout("Feedback", subtitle: "Feature requests", image: .mail)
                }
                
                DiscoverCard("https://wiki.bisquit.host") {
                    DiscoverCardLayout("Wiki", subtitle: "How to...?", image: .wiki)
                }
                
                DiscoverCard("https://mgr.bisquit.host") {
                    DiscoverCardLayout("Panel", subtitle: "Web", image: .safari)
                }
                
                NavigationLink {
                    MapView()
                } label: {
                    DiscoverCardLayout("Maps", subtitle: "Best places", image: .maps)
                }
                
                DiscoverCard("https://bisquit.host/policy.pdf") {
                    DiscoverCardLayout("Privacy Policy", subtitle: "Document", image: .docBlue)
                }
                
                DiscoverCard("https://bisquit.host/terms.pdf") {
                    DiscoverCardLayout("ToS", subtitle: "Document", image: .docYellow)
                }
            }
            .padding(.vertical, 20)
        }
        .scenePadding(.horizontal)
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
