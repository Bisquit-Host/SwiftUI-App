import SwiftUI
import Calagopus

extension ModpackProvider {
    var img: ImageResource {
        switch self {
        case .atlauncher: .atLauncher
        case .curseforge: .curseForge
        case .feedthebeast: .FTB
        case .modrinth: .modrinth
        case .technic: .technicpack
        case .voidswrath: .voidswrath
        }
    }
}
