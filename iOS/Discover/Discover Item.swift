import SwiftUI

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
