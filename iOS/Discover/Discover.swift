import ScrechKit
import SafariCover

struct Discover: View {
    @EnvironmentObject private var store: ValueStore
    
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
                .listRowBackground(store.transparentList ? .clear : Color.list)
                
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
                .listRowBackground(store.transparentList ? .clear : Color.list)
                
                Section("Apps") {
                    ListButton(
                        "More apps by Bisquit.Host",
                        icon: "app.gift",
                        actionIcon: "link",
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
                .listRowBackground(store.transparentList ? .clear : Color.list)
                
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
                        icon: "app.connected.to.app.below.fill",
                        actionIcon: "link",
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
                .listRowBackground(store.transparentList ? .clear : Color.list)
                
                NavigationLink {
                    MapView()
                } label: {
                    ListButton("Places we recommend", icon: "map")
                }
                .listRowBackground(store.transparentList ? .clear : Color.list)
                
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
                            url: "https://bisquit.host/offer.pdf",
                            color: .secondary
                        )
                    )
                }
                .listRowBackground(store.transparentList ? .clear : Color.list)
            }
            .scrollContentBackground(store.transparentSheet ? .hidden : .visible)
            .presentationBackground(store.transparentSheet ? .ultraThinMaterial : .regular)
            .scrollIndicators(.never)
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
