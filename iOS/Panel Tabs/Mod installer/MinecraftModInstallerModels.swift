import Foundation

enum MinecraftModProvider: String, CaseIterable, Identifiable {
    case curseforge, modrinth
    
    init?(providerValue: String?) {
        guard let providerValue = providerValue?.lowercased() else {
            return nil
        }
        
        self.init(rawValue: providerValue)
    }
    
    var id: String {
        rawValue
    }
    
    var name: String {
        switch self {
        case .curseforge: "CurseForge"
        case .modrinth: "Modrinth"
        }
    }
}

struct MinecraftCatalogProject: Identifiable, Hashable {
    let id: String
    let name: String
    let description: String
    let url: String?
    let iconURLString: String?
    let externalURL: String?
    
    var iconURL: URL? {
        guard let iconURLString else {
            return nil
        }
        
        return URL(string: iconURLString)
    }
    
    var webPageURL: String? {
        for value in [externalURL, url] {
            guard let value else { continue }
            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard trimmed.isEmpty == false else {
                continue
            }
            
            return trimmed
        }
        
        return nil
    }
}

struct MinecraftCatalogVersion: Identifiable, Hashable {
    let id: String
    let name: String
}

struct MinecraftProjectUpdate: Hashable {
    let id: String
    let name: String
}

struct MinecraftInstalledProject: Identifiable, Hashable {
    let path: String
    let provider: String?
    let projectId: String?
    let projectName: String?
    let versionId: String?
    let versionName: String?
    let iconURLString: String?
    let update: MinecraftProjectUpdate?
    
    var id: String {
        path
    }
    
    var iconURL: URL? {
        guard let iconURLString else {
            return nil
        }
        
        return URL(string: iconURLString)
    }
    
    var fileName: String {
        path.split(separator: "/").last.map(String.init) ?? path
    }
}

struct MinecraftPagination: Hashable {
    var currentPage = 1
    var totalPages = 1
    var total = 0
}
