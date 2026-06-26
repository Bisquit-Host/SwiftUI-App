import Calagopus
import SwiftUI

extension ModManagerProvider {
    var img: ImageResource {
        switch self {
        case .curseforge: .curseForge
        case .modrinth: .modrinth
        }
    }
}
