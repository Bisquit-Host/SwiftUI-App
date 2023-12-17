import SwiftUI
import OrderedCollections

@Observable
final class DiscoverVM {
    struct DiscoverItem {
        let name, icon, url: String
        let color: Color
        
        init(_ name: String,
             icon: String,
             url: String,
             color: Color = .blue
        ) {
            self.name = name
            self.icon = icon
            self.url = url
            self.color = color
        }
    }
    
    let sections: OrderedDictionary<String, [DiscoverItem]> = [
        "Support": [
            .init("App support",
                  icon: "questionmark.app.dashed",
                  url: "https://topscrech.dev/app/support/",
                  color: .purple),
            
                .init("Hosting support",
                      icon: "questionmark.bubble",
                      url: "https://my.bisquit.host/login",
                      color: .purple),
        ],
        
        "Apps": [
            .init("Android version",
                  icon: "flipphone",
                  url: "https://apps.rustore.ru/app/net.turbovadim.bisquithost2"),
            
                .init("Other apps",
                      icon: "app.gift",
                      url: "https://apps.apple.com/au/developer/sergei-saliukov/id1639409936"),
            
                .init("Pterodactyl panel",
                      icon: "text.and.command.macwindow",
                      url: "https://mgr.bisquit.host"),
        ],
        
        "Other": [
            .init("Wiki / FAQ",
                  icon: "books.vertical",
                  url: "https://wiki.bisquit.host",
                  color: .secondary),
            
                .init("System Status",
                      icon: "speedometer",
                      url: "https://status.bisquit.host/status/bisquithost",
                      color: .secondary),
            
                .init("GitHub",
                      icon: "app.connected.to.app.below.fill",
                      url: "https://github.com/TopScrech",
                      color: .secondary)
        ]
    ]
}
