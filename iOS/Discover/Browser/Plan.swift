import SwiftUI

enum Plan: String, Identifiable, CaseIterable {
    case mc,
         mcru,
         vds,
         web,
         bot
    
    var path: String {
        switch self {
        case .mc: "minecraft"
        case .mcru: "minecraft"
        case .vds: "vds"
        case .web: "webhosting"
        case .bot: "bot"
        }
    }
    
    var localized: LocalizedStringKey {
        switch self {
        case .mc: "Minecraft"
        case .mcru: "Minecraft (Ru)"
        case .vds: "VDS"
        case .web: "Web"
        case .bot: "Bot"
        }
    }
    
    var id: String {
        self.rawValue
    }
}
