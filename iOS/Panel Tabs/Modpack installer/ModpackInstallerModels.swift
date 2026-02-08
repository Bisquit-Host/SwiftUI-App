import Foundation

enum ModpackProvider: String, CaseIterable, Identifiable {
    case atlauncher, curseforge, feedthebeast, modrinth, technic, voidswrath
    
    var id: String {
        rawValue
    }
    
    var name: String {
        switch self {
        case .atlauncher: "ATLauncher"
        case .curseforge: "CurseForge"
        case .feedthebeast: "FeedTheBeast"
        case .modrinth: "Modrinth"
        case .technic: "Technic"
        case .voidswrath: "VoidsWrath"
        }
    }
}

struct InstalledModpack: Hashable {
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
}
