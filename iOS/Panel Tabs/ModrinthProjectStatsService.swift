import Foundation

struct ModrinthProjectStats: Sendable {
    let likes: Int?
    let downloads: Int?
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

        guard let encodedIdentifier = identifier.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = URL(string: "https://api.modrinth.com/v2/project/\(encodedIdentifier)") else {
            return nil
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 15
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bisquit-Host", forHTTPHeaderField: "User-Agent")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                return nil
            }

            let payload = try JSONDecoder().decode(ModrinthProjectPayload.self, from: data)
            let likes = payload.likes ?? payload.followers ?? payload.follows
            let stats = ModrinthProjectStats(likes: likes, downloads: payload.downloads)
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
}

private extension MinecraftCatalogProject {
    nonisolated var modrinthSlug: String? {
        let candidateURL = [externalURL, url]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { $0.isEmpty == false }

        guard let rawURL = candidateURL,
              let url = URL(string: rawURL),
              let host = url.host?.lowercased(),
              host.contains("modrinth.com") else {
            return nil
        }

        let components = url.pathComponents.filter { $0 != "/" }
        guard components.count >= 2 else {
            return nil
        }

        let slug = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
        guard slug.isEmpty == false else {
            return nil
        }

        return slug
    }
}
