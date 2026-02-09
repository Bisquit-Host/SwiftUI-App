import SwiftUI

enum ModManagerProvider: String, CaseIterable, Identifiable {
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
    
    var img: ImageResource {
        switch self {
        case .curseforge: .curseForge
        case .modrinth: .modrinth
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
    let likes: Int?
    let downloads: Int?
    let installs: Int?
    let plays: Int?
    let minimumRAMMB: Int?
    let recommendedRAMMB: Int?
    let javaVersion: String?
    let modLoader: String?
    let lastUpdatedAt: Date?
    let releasedAt: Date?

    init(
        id: String,
        name: String,
        description: String,
        url: String?,
        iconURLString: String?,
        externalURL: String?,
        likes: Int? = nil,
        downloads: Int? = nil,
        installs: Int? = nil,
        plays: Int? = nil,
        minimumRAMMB: Int? = nil,
        recommendedRAMMB: Int? = nil,
        javaVersion: String? = nil,
        modLoader: String? = nil,
        lastUpdatedAt: Date? = nil,
        releasedAt: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.url = url
        self.iconURLString = iconURLString
        self.externalURL = externalURL
        self.likes = likes
        self.downloads = downloads
        self.installs = installs
        self.plays = plays
        self.minimumRAMMB = minimumRAMMB
        self.recommendedRAMMB = recommendedRAMMB
        self.javaVersion = javaVersion
        self.modLoader = modLoader
        self.lastUpdatedAt = lastUpdatedAt
        self.releasedAt = releasedAt
    }
    
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

    var hasStats: Bool {
        likes != nil || downloads != nil || installs != nil || plays != nil
    }

    var hasFTBMetadata: Bool {
        installs != nil || plays != nil || minimumRAMMB != nil || recommendedRAMMB != nil || javaVersion != nil || modLoader != nil || lastUpdatedAt != nil || releasedAt != nil
    }

    func replacingStats(likes: Int?, downloads: Int?) -> MinecraftCatalogProject {
        MinecraftCatalogProject(
            id: id,
            name: name,
            description: description,
            url: url,
            iconURLString: iconURLString,
            externalURL: externalURL,
            likes: likes ?? self.likes,
            downloads: downloads ?? self.downloads,
            installs: installs,
            plays: plays,
            minimumRAMMB: minimumRAMMB,
            recommendedRAMMB: recommendedRAMMB,
            javaVersion: javaVersion,
            modLoader: modLoader,
            lastUpdatedAt: lastUpdatedAt,
            releasedAt: releasedAt
        )
    }
    
    func replacingTimeline(lastUpdatedAt: Date?, releasedAt: Date?) -> MinecraftCatalogProject {
        MinecraftCatalogProject(
            id: id,
            name: name,
            description: description,
            url: url,
            iconURLString: iconURLString,
            externalURL: externalURL,
            likes: likes,
            downloads: downloads,
            installs: installs,
            plays: plays,
            minimumRAMMB: minimumRAMMB,
            recommendedRAMMB: recommendedRAMMB,
            javaVersion: javaVersion,
            modLoader: modLoader,
            lastUpdatedAt: lastUpdatedAt ?? self.lastUpdatedAt,
            releasedAt: releasedAt ?? self.releasedAt
        )
    }

    func replacingFTBMetadata(
        installs: Int?,
        plays: Int?,
        minimumRAMMB: Int?,
        recommendedRAMMB: Int?,
        javaVersion: String?,
        modLoader: String?,
        lastUpdatedAt: Date?,
        releasedAt: Date?
    ) -> MinecraftCatalogProject {
        MinecraftCatalogProject(
            id: id,
            name: name,
            description: description,
            url: url,
            iconURLString: iconURLString,
            externalURL: externalURL,
            likes: likes,
            downloads: downloads,
            installs: installs ?? self.installs,
            plays: plays ?? self.plays,
            minimumRAMMB: minimumRAMMB ?? self.minimumRAMMB,
            recommendedRAMMB: recommendedRAMMB ?? self.recommendedRAMMB,
            javaVersion: javaVersion ?? self.javaVersion,
            modLoader: modLoader ?? self.modLoader,
            lastUpdatedAt: lastUpdatedAt ?? self.lastUpdatedAt,
            releasedAt: releasedAt ?? self.releasedAt
        )
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
