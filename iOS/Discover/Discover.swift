import ScrechKit
import SafariCover

struct Discover: View {
    @EnvironmentObject private var settings: ValueStorage
    
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
                .listRowBackground(settings.transparentList ? .clear : Color.list)
                
                Section("Support") {
                    DiscoverCard(
                        DiscoverItem(
                            "App support",
                            icon: "questionmark.app.dashed",
                            url: "https://topscrech.dev/app/support/",
                            color: .purple
                        )
                    )
                    
                    DiscoverCard(
                        DiscoverItem(
                            "Hosting support",
                            icon: "questionmark.bubble",
                            url: "https://my.bisquit.host/login",
                            color: .purple
                        )
                    )
                }
                .listRowBackground(settings.transparentList ? .clear : Color.list)
                
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
                .listRowBackground(settings.transparentList ? .clear : Color.list)
                
                Section("Other") {
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
                            "Wiki / FAQ",
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
                }
                .listRowBackground(settings.transparentList ? .clear : Color.list)
                
                NavigationLink {
                    MapView()
                } label: {
                    ListButton("Places we recommend", icon: "map")
                }
                .listRowBackground(settings.transparentList ? .clear : Color.list)
            }
            .scrollContentBackground(settings.transparentSheet ? .hidden : .visible)
            .presentationBackground(settings.transparentSheet ? .ultraThinMaterial : .regular)
            .scrollIndicators(.never)
        }
        .sheet($sheetConfigurations) {
            Browser()
        }
    }
}

#Preview {
    Discover()
        .environmentObject(ValueStorage())
}
