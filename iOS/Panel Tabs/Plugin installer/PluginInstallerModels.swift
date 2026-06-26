import SwiftUI
import Calagopus

extension PluginProvider {
    var img: ImageResource {
        switch self {
        case .curseforge: .curseForge
        case .hangar: .hangar
        case .modrinth: .modrinth
        case .polymart: .polymart
        case .spigotmc: .spigotMC
        }
    }
}
