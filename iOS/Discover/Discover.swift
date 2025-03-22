//import ScrechKit
//import SafariCover
//import MailCover
//
//struct Discover: View {
//    @State private var sheetConfigurations = false
//    @State private var showMailCover = false
//    
//    var body: some View {
//        NavigationView {
//            List {
//                Section {
//                    ListButton("Available configurations", actionIcon: "externaldrive.badge.plus") {
//                        sheetConfigurations = true
//                    }
//                    .foregroundStyle(.foreground)
//                }
//                .transparentSection()
//                
//                Section("Apps") {
//                    ListButton(
//                        "More apps by Bisquit.Host",
//                        actionIcon: "app.gift",
//                        color: .blue
//                    ) {
//                        openSafari("https://apps.apple.com/au/developer/sergei-saliukov/id1639409936")
//                    }
//                    
//                    DiscoverCard(
//                        DiscoverItem(
//                            "Web panel",
//                            icon: "text.and.command.macwindow",
//                            url: "https://mgr.bisquit.host"
//                        )
//                    )
//                }
//                .transparentSection()
//                
//                Section {
//                    DiscoverCard(
//                        DiscoverItem(
//                            "System status",
//                            icon: "speedometer",
//                            url: "https://status.bisquit.host/status/bisquithost",
//                            color: .gray
//                        )
//                    )
//                    
//                    DiscoverCard(
//                        DiscoverItem(
//                            "Wiki",
//                            icon: "books.vertical",
//                            url: "https://wiki.bisquit.host",
//                            color: .secondary
//                        )
//                    )
//                    
//                    DiscoverCard(
//                        DiscoverItem(
//                            "Client role in the Discord channel",
//                            icon: "person",
//                            url: "https://my.bisquit.host/discord.php",
//                            color: .secondary
//                        )
//                    )
//                }
//                .transparentSection()
//                
//                NavigationLink {
//                    MapView()
//                } label: {
//                    ListButton("Places we recommend", actionIcon: "map")
//                }
//                .transparentSection()
//                
//                Section("Support") {
//                    DiscoverCard(
//                        DiscoverItem(
//                            "App support",
//                            icon: "questionmark.app.dashed",
//                            url: "https://topscrech.dev/app/support",
//                            color: .purple
//                        )
//                    )
//                    
//                    DiscoverCard(
//                        DiscoverItem(
//                            "Hosting support",
//                            icon: "questionmark.bubble",
//                            url: "https://my.bisquit.host/login",
//                            color: .purple
//                        )
//                    )
//                }
//                .transparentSection()
//                
//                Section {
//                    Button {
//                        openSafari("https://t.me/bisquit_host_chat")
//                    } label: {
//                        HStack {
//                            Text("Telegram Chat")
//                            
//                            Spacer()
//                            
//                            Image(systemName: "paperplane")
//                                .secondary()
//                        }
//                    }
//                    
//                    Button {
//                        showMailCover = true
//                    } label: {
//                        HStack {
//                            Text("Mail")
//                            
//                            Spacer()
//                            
//                            Image(systemName: "envelope")
//                                .secondary()
//                        }
//                    }
//                }
//                .transparentSection()
//                .foregroundStyle(.foreground)
//                
//                Section {
//                    DiscoverCard(
//                        DiscoverItem(
//                            "Privacy Policy",
//                            icon: "text.document",
//                            url: "https://bisquit.host/policy.pdf",
//                            color: .secondary
//                        )
//                    )
//                    
//                    DiscoverCard(
//                        DiscoverItem(
//                            "Offer",
//                            icon: "text.document",
//                            url: "https://bisquit.host/terms.pdf",
//                            color: .secondary
//                        )
//                    )
//                }
//                .transparentSection()
//            }
//            .transparentList()
//            .scrollIndicators(.never)
//            .ornamentDismissButton()
//            .mailCover(
//                $showMailCover,
//                message: "Hello there! \n",
//                subject: "Bisquit.Host Feedback",
//                recipients: ["topscrech@icloud.com"]
//            )
//        }
//        .sheet($sheetConfigurations) {
//            BrowserParent()
//        }
//    }
//}
//
//#Preview {
//    Discover()
//        .environmentObject(ValueStore())
//}
