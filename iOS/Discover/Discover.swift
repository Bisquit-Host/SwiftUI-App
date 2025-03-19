import ScrechKit
import SafariCover

struct Discover: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var sheetConfigurations = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ListButton("Available configurations", actionIcon: "externaldrive.badge.plus") {
                        sheetConfigurations = true
                    }
                    .foregroundStyle(.foreground)
                }
                .transparentSection()
                
                Section("Support") {
                    DiscoverCard(
                        DiscoverItem(
                            "App Support",
                            icon: "questionmark.app.dashed",
                            url: "https://topscrech.dev/app/support/",
                            color: .purple
                        )
                    )
                    
                    DiscoverCard(
                        DiscoverItem(
                            "Hosting Support",
                            icon: "questionmark.bubble",
                            url: "https://my.bisquit.host/login",
                            color: .purple
                        )
                    )
                }
                .transparentSection()
                
                Section("Apps") {
                    ListButton(
                        "More apps by Bisquit.Host",
                        actionIcon: "app.gift",
                        color: .blue
                    ) {
                        openSafari("https://apps.apple.com/au/developer/sergei-saliukov/id1639409936")
                    }
                    
                    DiscoverCard(
                        DiscoverItem(
                            "Web panel",
                            icon: "text.and.command.macwindow",
                            url: "https://mgr.bisquit.host"
                        )
                    )
                }
                .transparentSection()
                
                Section {
                    DiscoverCard(
                        DiscoverItem(
                            "System status",
                            icon: "speedometer",
                            url: "https://status.bisquit.host/status/bisquithost",
                            color: .gray
                        )
                    )
                    
                    DiscoverCard(
                        DiscoverItem(
                            "Wiki",
                            icon: "books.vertical",
                            url: "https://wiki.bisquit.host",
                            color: .secondary
                        )
                    )
                    
                    ListButton(
                        "GitHub",
                        actionIcon: "app.connected.to.app.below.fill",
                        color: .secondary
                    ) {
                        openSafari("https://github.com/TopScrech")
                    }
                    
                    DiscoverCard(
                        DiscoverItem(
                            "Client role in the Discord channel",
                            icon: "person",
                            url: "https://my.bisquit.host/discord.php",
                            color: .secondary
                        )
                    )
                }
                .transparentSection()
                
                NavigationLink {
                    MapView()
                } label: {
                    ListButton("Places we recommend", actionIcon: "map")
                }
                .transparentSection()
                
                Section {
                    DiscoverCard(
                        DiscoverItem(
                            "Privacy Policy",
                            icon: "text.document",
                            url: "https://bisquit.host/policy.pdf",
                            color: .secondary
                        )
                    )
                    
                    DiscoverCard(
                        DiscoverItem(
                            "Offer",
                            icon: "text.document",
                            url: "https://bisquit.host/terms.pdf",
                            color: .secondary
                        )
                    )
                }
                .transparentSection()
            }
            .transparentList()
            .scrollIndicators(.never)
            .ornamentDismissButton()
        }
        .sheet($sheetConfigurations) {
            BrowserParent()
        }
    }
}

#Preview {
    Discover()
        .environmentObject(ValueStore())
}
