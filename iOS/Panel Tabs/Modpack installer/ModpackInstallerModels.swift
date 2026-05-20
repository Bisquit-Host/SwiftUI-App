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

struct FTBModpackVersionMod: Hashable, Identifiable {
    let id: String
    let name: String
    let sourceURLString: String?
    let sha1: String?
    let clientOnly: Bool
    let serverOnly: Bool
    
    var sourceURL: URL? {
        guard let sourceURLString else { return nil }
        return URL(string: sourceURLString)
    }
    
    var fallbackDisplayName: String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard trimmed.isEmpty == false else {
            return "Unknown mod"
        }
        
        let baseName = URL(fileURLWithPath: trimmed).deletingPathExtension().lastPathComponent
        
        return baseName
            .replacingOccurrences(of: "_", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct FTBModpackAuthor: Hashable, Identifiable {
    let id: String
    let name: String
    let profileURLString: String?
}

struct FTBModpackVersionModMetadata: Hashable {
    let displayName: String?
    let iconURLString: String?
    let projectURLString: String?
    let authors: [FTBModpackAuthor]
    
    var iconURL: URL? {
        guard let iconURLString else { return nil }
        return URL(string: iconURLString)
    }
}
