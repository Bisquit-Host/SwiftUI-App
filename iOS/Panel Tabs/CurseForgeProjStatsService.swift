import Foundation
import Calagopus

struct CurseForgeProjStats: Sendable {
    let downloads: Int?
}

enum CurseForgeProjCategory: String, Sendable {
    case mcMods = "mc-mods",
         modpacks,
         bukkitPlugins = "bukkit-plugins"
}

actor CurseForgeProjStatsService {
    static let shared = CurseForgeProjStatsService()
    
    private struct CacheEntry {
        let stats: CurseForgeProjStats
        let createdAt: Date
    }
    
    private var cache: [String: CacheEntry] = [:]
    private let cacheTTL: TimeInterval = 60 * 10
    
    func fetchStats(for projects: [MinecraftCatalogProject], category: CurseForgeProjCategory) async -> [String: CurseForgeProjStats] {
        await withTaskGroup(of: (String, CurseForgeProjStats?).self, returning: [String: CurseForgeProjStats].self) { group in
            for project in projects {
                group.addTask {
                    guard let identifier = Self.identifier(for: project, category: category) else {
                        return (project.id, nil)
                    }
                    
                    let stats = await self.fetchStats(forIdentifier: identifier, category: category)
                    return (project.id, stats)
                }
            }
            
            var output: [String: CurseForgeProjStats] = [:]
            
            for await (projectId, stats) in group {
                guard let stats else {
                    continue
                }
                
                output[projectId] = stats
            }
            
            return output
        }
    }
    
    private func fetchStats(forIdentifier identifier: String, category: CurseForgeProjCategory) async -> CurseForgeProjStats? {
        let key = "\(category.rawValue):\(identifier.lowercased())"
        
        if let cached = cache[key], Date().timeIntervalSince(cached.createdAt) < cacheTTL {
            return cached.stats
        }
        
        guard let encodedIdentifier = identifier.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            return nil
        }
        
        do {
            let data = try await fetchMinecraftInstallerExternalData(
                urlString: "https://api.cfwidget.com/minecraft/\(category.rawValue)/\(encodedIdentifier)",
                timeout: 15
            )
            let payload = try JSONDecoder().decode(CurseForgeWidgetPayload.self, from: data)
            let stats = CurseForgeProjStats(downloads: payload.downloads?.total)
            cache[key] = CacheEntry(stats: stats, createdAt: Date())
            return stats
        } catch {
            return nil
        }
    }
    
    nonisolated private static func identifier(for project: MinecraftCatalogProject, category: CurseForgeProjCategory) -> String? {
        let trimmedId = project.id.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedId.isEmpty == false, Int(trimmedId) != nil {
            return trimmedId
        }
        
        if let slug = project.curseForgeSlug(category: category) {
            return slug
        }
        
        if trimmedId.isEmpty == false {
            return trimmedId
        }
        
        return nil
    }
}

nonisolated private struct CurseForgeWidgetPayload: Decodable {
    let downloads: CurseForgeWidgetDownloadsPayload?
}

nonisolated private struct CurseForgeWidgetDownloadsPayload: Decodable {
    let monthly: Int?
    let total: Int?
    
    private enum CodingKeys: String, CodingKey {
        case monthly, total
    }
    
    init(from decoder: Decoder) throws {
        if let container = try? decoder.singleValueContainer(),
           let intValue = try? container.decode(Int.self) {
            monthly = nil
            total = intValue
            return
        }
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        monthly = try container.decodeIfPresent(Int.self, forKey: .monthly)
        total = try container.decodeIfPresent(Int.self, forKey: .total)
    }
}

private extension MinecraftCatalogProject {
    nonisolated func curseForgeSlug(category: CurseForgeProjCategory) -> String? {
        let candidateURL = [externalURL, url]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { $0.isEmpty == false }
        
        guard
            let candidateURL,
            let parsedURL = URL(string: candidateURL),
            let host = parsedURL.host?.lowercased(),
            host.contains("curseforge.com")
        else {
            return nil
        }
        
        let components = parsedURL.pathComponents.filter { $0 != "/" }
        
        guard components.count >= 3 else {
            return nil
        }
        
        if components[0].lowercased() == "minecraft",
           components[1].lowercased() == category.rawValue {
            let slug = components[2].trimmingCharacters(in: .whitespacesAndNewlines)
            return slug.isEmpty ? nil : slug
        }
        
        guard
            let categoryIndex = components.firstIndex(where: { $0.lowercased() == category.rawValue }),
            components.indices.contains(categoryIndex + 1)
        else {
            return nil
        }
        
        let slug = components[categoryIndex + 1].trimmingCharacters(in: .whitespacesAndNewlines)
        return slug.isEmpty ? nil : slug
    }
}
