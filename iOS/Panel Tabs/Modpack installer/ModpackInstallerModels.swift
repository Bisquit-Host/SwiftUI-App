import SwiftUI

enum ModpackProvider: String, CaseIterable, Identifiable {
    case atlauncher, curseforge, feedthebeast, modrinth, technic, voidswrath
    
    var id: String {
        rawValue
    }
    
    var name: String {
        switch self {
        case .atlauncher: "ATLauncher"
        case .curseforge: "CurseForge"
        case .feedthebeast: "FTB"
        case .modrinth: "Modrinth"
        case .technic: "Technic"
        case .voidswrath: "VoidsWrath"
        }
    }
    
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

struct InstalledModpack: Hashable, Identifiable {
    let id: String
    let provider: String
    let name: String
    let description: String
    let url: String?
    let iconURLString: String?
    
    var iconURL: URL? {
        guard let iconURLString else { return nil }
        return URL(string: iconURLString)
    }
    
    var webPageURL: String? {
        guard let url else { return nil }
        let trimmed = url.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard trimmed.isEmpty == false else {
            return nil
        }
        
        return trimmed
    }
}
