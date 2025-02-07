import SwiftUI

enum Plan: String, Identifiable, CaseIterable {
    case mc,
         vds,
         web,
         bot
    
    var path: String {
        switch self {
        case .mc: "minecraft"
        case .vds: "vds"
        case .web: "webhosting"
        case .bot: "bot"
        }
    }
    
    var localized: LocalizedStringKey {
        switch self {
        case .mc: "Minecraft"
        case .vds: "VDS"
        case .web: "Web"
        case .bot: "Bot"
        }
    }
    
    var id: String {
        self.rawValue
    }
}
