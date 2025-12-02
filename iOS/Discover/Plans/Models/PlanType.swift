import SwiftUI

enum PlanType: String, Identifiable, CaseIterable {
    case game, cloud, web, bot
    
    var id: String { rawValue }
    
    var localized: LocalizedStringKey {
        switch self {
        case .game:  "Minecraft"
        case .cloud: "VDS"
        case .web: "Web"
        case .bot: "Bot"
        }
    }
}
