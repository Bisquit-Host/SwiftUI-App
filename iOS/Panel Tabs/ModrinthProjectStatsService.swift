import Foundation
import Calagopus

struct ModrinthProjectStats: Sendable {
    let likes: Int?
    let downloads: Int?
    let lastUpdatedAt: Date?
    let releasedAt: Date?
}

actor ModrinthProjectStatsService {
    static let shared = ModrinthProjectStatsService()
    
    private struct CacheEntry {
        let stats: ModrinthProjectStats
        let createdAt: Date
    }
    
    private var cache: [String: CacheEntry] = [:]
    private let cacheTTL: TimeInterval = 60 * 10
    
    func fetchStats(for projects: [MinecraftCatalogProject]) async -> [String: ModrinthProjectStats] {
        await withTaskGroup(of: (String, ModrinthProjectStats?).self, returning: [String: ModrinthProjectStats].self) { group in
            for project in projects {
                group.addTask {
                    guard let identifier = Self.identifier(for: project) else {
                        return (project.id, nil)
                    }
                    
                    let stats = await self.fetchStats(forIdentifier: identifier)
                    return (project.id, stats)
                }
            }
            
            var output: [String: ModrinthProjectStats] = [:]
            
            for await (projectId, stats) in group {
                guard let stats else {
                    continue
                }
                
                output[projectId] = stats
            }
            
            return output
        }
    }
    
    private func fetchStats(forIdentifier identifier: String) async -> ModrinthProjectStats? {
        let key = identifier.lowercased()
        
        if let cached = cache[key], Date().timeIntervalSince(cached.createdAt) < cacheTTL {
            return cached.stats
        }
        
        guard let encodedIdentifier = identifier.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            return nil
        }
        
        do {
            let data = try await fetchMinecraftInstallerExternalData(
                urlString: "https://api.modrinth.com/v2/project/\(encodedIdentifier)",
                timeout: 15
            )
            let payload = try JSONDecoder().decode(ModrinthProjectPayload.self, from: data)
            let likes = payload.likes ?? payload.followers ?? payload.follows
            
            let stats = ModrinthProjectStats(
                likes: likes,
                downloads: payload.downloads,
                lastUpdatedAt: payload.updated?.value ?? payload.dateModified?.value,
                releasedAt: payload.published?.value ?? payload.dateCreated?.value
            )
            
            cache[key] = CacheEntry(stats: stats, createdAt: Date())
            return stats
        } catch {
            return nil
        }
    }
    
    nonisolated private static func identifier(for project: MinecraftCatalogProject) -> String? {
        if let slug = project.modrinthSlug {
            return slug
        }
        
        let trimmedId = project.id.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard trimmedId.isEmpty == false else {
            return nil
        }
        
        return trimmedId
    }
}

nonisolated private struct ModrinthProjectPayload: Decodable {
    let likes: Int?
    let follows: Int?
    let followers: Int?
    let downloads: Int?
    let updated: ModrinthLossyDate?
    let published: ModrinthLossyDate?
    let dateModified: ModrinthLossyDate?
    let dateCreated: ModrinthLossyDate?
    
    private enum CodingKeys: String, CodingKey {
        case likes, follows, followers, downloads, updated, published,
             dateModified = "date_modified",
             dateCreated = "date_created"
    }
}

private struct ModrinthLossyDate: Decodable {
    let value: Date?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let stringValue = try? container.decode(String.self) {
            value = Self.isoDate(stringValue)
            return
        }
        
        if let intValue = try? container.decode(Int.self) {
            value = Self.unixDate(TimeInterval(intValue))
            return
        }
        
        if let doubleValue = try? container.decode(Double.self) {
            value = Self.unixDate(doubleValue)
            return
        }
        
        value = nil
    }
    
    private static func isoDate(_ value: String) -> Date? {
        let withFractions = ISO8601DateFormatter()
        withFractions.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = withFractions.date(from: value) {
            return date
        }
        
        let standard = ISO8601DateFormatter()
        standard.formatOptions = [.withInternetDateTime]
        
        return standard.date(from: value)
    }
    
    private static func unixDate(_ value: TimeInterval) -> Date? {
        guard value > 0 else {
            return nil
        }
        
        let seconds = value > 10_000_000_000 ? (value / 1000) : value
        return Date(timeIntervalSince1970: seconds)
    }
}

private extension MinecraftCatalogProject {
    nonisolated var modrinthSlug: String? {
        for rawURL in [externalURL, url] {
            guard let rawURL else { continue }
            let trimmed = rawURL.trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard
                trimmed.isEmpty == false,
                let parsedURL = URL(string: trimmed),
                let host = parsedURL.host?.lowercased(),
                host.contains("modrinth.com")
            else {
                continue
            }
            
            let components = parsedURL.pathComponents.filter { $0 != "/" }
            
            guard components.count >= 2 else {
                continue
            }
            
            let slug = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard slug.isEmpty == false else {
                continue
            }
            
            return slug
        }
        
        return nil
    }
}
