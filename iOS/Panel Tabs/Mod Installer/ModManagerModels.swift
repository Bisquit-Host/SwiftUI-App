import SwiftUI
import Calagopus

extension ModManagerProvider {
    var img: ImageResource {
        switch self {
        case .curseforge: .curseForge
        case .modrinth: .modrinth
        }
    }
}
