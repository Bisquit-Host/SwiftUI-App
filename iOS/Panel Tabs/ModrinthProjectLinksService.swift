import Foundation

struct ModrinthProjectLink: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let url: String
    let systemImage: String
}

actor ModrinthProjectLinksService {
    static let shared = ModrinthProjectLinksService()
    
    private struct CacheEntry {
        let links: [ModrinthProjectLink]
        let createdAt: Date
    }
    
    private var cache: [String: CacheEntry] = [:]
    private let cacheTTL: TimeInterval = 60 * 10
    
    func fetchLinks(for project: MinecraftCatalogProject) async -> [ModrinthProjectLink] {
        guard let identifier = Self.identifier(for: project) else {
            return []
        }
        
        return await fetchLinks(forIdentifier: identifier, fallbackProjectURL: project.webPageURL)
    }
    
    private func fetchLinks(forIdentifier identifier: String, fallbackProjectURL: String?) async -> [ModrinthProjectLink] {
        let key = identifier.lowercased()
        
        if let cached = cache[key], Date().timeIntervalSince(cached.createdAt) < cacheTTL {
            return cached.links
        }
        
        guard let encodedIdentifier = identifier.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = URL(string: "https://api.modrinth.com/v2/project/\(encodedIdentifier)") else {
            return []
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 15
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bisquit-Host", forHTTPHeaderField: "User-Agent")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                return []
            }
            
            let payload = try JSONDecoder().decode(ModrinthProjectLinksPayload.self, from: data)
            let links = Self.buildLinks(payload, fallbackProjectURL: fallbackProjectURL)
            cache[key] = CacheEntry(links: links, createdAt: Date())
            return links
        } catch {
            return []
        }
    }
    
    nonisolated private static func identifier(for project: MinecraftCatalogProject) -> String? {
        for rawURL in [project.externalURL, project.url] {
            guard let rawURL else { continue }
            
            let trimmed = rawURL.trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard trimmed.isEmpty == false,
                  let parsedURL = URL(string: trimmed),
                  let host = parsedURL.host?.lowercased(),
                  host.contains("modrinth.com") else {
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
        
        let trimmedId = project.id.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard trimmedId.isEmpty == false else {
            return nil
        }
        
        return trimmedId
    }
    
    nonisolated private static func buildLinks(_ payload: ModrinthProjectLinksPayload, fallbackProjectURL: String?) -> [ModrinthProjectLink] {
        var links: [ModrinthProjectLink] = []
        var seenURLs = Set<String>()
        
        func append(title: String, rawURL: String?, systemImage: String) {
            guard let normalizedURL = normalizedURL(from: rawURL) else {
                return
            }
            
            let dedupeKey = normalizedURL.lowercased()
            
            guard seenURLs.insert(dedupeKey).inserted else {
                return
            }
            
            links.append(
                ModrinthProjectLink(
                    id: "\(title)::\(normalizedURL)",
                    title: title,
                    url: normalizedURL,
                    systemImage: systemImage
                )
            )
        }
        
        append(
            title: "Project page",
            rawURL: fallbackProjectURL ?? payload.projectPageURL,
            systemImage: "safari"
        )
        append(title: "Source code", rawURL: payload.sourceURL, systemImage: "curlybraces")
        append(title: "Issues", rawURL: payload.issuesURL, systemImage: "exclamationmark.bubble")
        append(title: "Wiki", rawURL: payload.wikiURL, systemImage: "book")
        append(title: "Discord", rawURL: payload.discordURL, systemImage: "person.3")
        
        for donation in payload.donationURLs ?? [] {
            let donationTitle = donation.label
            append(title: donationTitle, rawURL: donation.url, systemImage: "heart")
        }
        
        return links
    }
    
    nonisolated private static func normalizedURL(from rawURL: String?) -> String? {
        guard let rawURL else {
            return nil
        }
        
        let trimmed = rawURL.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard trimmed.isEmpty == false else {
            return nil
        }
        
        if let parsedURL = URL(string: trimmed), parsedURL.scheme != nil {
            return trimmed
        }
        
        if let parsedURL = URL(string: "https://\(trimmed)"), parsedURL.scheme != nil {
            return parsedURL.absoluteString
        }
        
        return nil
    }
}

nonisolated private struct ModrinthProjectLinksPayload: Decodable {
    let projectType: String?
    let slug: String?
    let issuesURL: String?
    let sourceURL: String?
    let wikiURL: String?
    let discordURL: String?
    let donationURLs: [ModrinthDonationLinkPayload]?
    
    private enum CodingKeys: String, CodingKey {
        case slug
        case projectType = "project_type"
        case issuesURL = "issues_url"
        case sourceURL = "source_url"
        case wikiURL = "wiki_url"
        case discordURL = "discord_url"
        case donationURLs = "donation_urls"
    }
    
    nonisolated var projectPageURL: String? {
        guard let slug else { return nil }
        let trimmedSlug = slug.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard trimmedSlug.isEmpty == false else {
            return nil
        }
        
        if let projectType {
            let trimmedType = projectType.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if trimmedType.isEmpty == false {
                return "https://modrinth.com/\(trimmedType)/\(trimmedSlug)"
            }
        }
        
        return "https://modrinth.com/project/\(trimmedSlug)"
    }
}

nonisolated private struct ModrinthDonationLinkPayload: Decodable {
    let id: String?
    let platform: String?
    let url: String?
    
    nonisolated var label: String {
        let base = (platform ?? id ?? "donation")
            .replacingOccurrences(of: "-", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard base.isEmpty == false else {
            return "Donate"
        }
        
        return "Donate (\(base.capitalized))"
    }
}
