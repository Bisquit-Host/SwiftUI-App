import Foundation

struct FTBModpackMetadata: Sendable {
    let installs: Int?
    let plays: Int?
    let minimumRAMMB: Int?
    let recommendedRAMMB: Int?
    let javaVersion: String?
    let modLoader: String?
    let lastUpdatedAt: Date?
    let releasedAt: Date?
}

actor FTBModpackMetadataService {
    static let shared = FTBModpackMetadataService()
    
    private struct CacheEntry {
        let metadata: FTBModpackMetadata
        let createdAt: Date
    }
    
    private var cache: [String: CacheEntry] = [:]
    private let cacheTTL: TimeInterval = 60 * 10
    
    func fetchMetadata(for projects: [MinecraftCatalogProject]) async -> [String: FTBModpackMetadata] {
        await withTaskGroup(of: (String, FTBModpackMetadata?).self, returning: [String: FTBModpackMetadata].self) { group in
            for project in projects {
                group.addTask {
                    guard let identifier = Self.identifier(for: project) else {
                        return (project.id, nil)
                    }
                    
                    let metadata = await self.fetchMetadata(forIdentifier: identifier)
                    return (project.id, metadata)
                }
            }
            
            var output: [String: FTBModpackMetadata] = [:]
            
            for await (projectId, metadata) in group {
                guard let metadata else {
                    continue
                }
                
                output[projectId] = metadata
            }
            
            return output
        }
    }
    
    private func fetchMetadata(forIdentifier identifier: String) async -> FTBModpackMetadata? {
        let key = identifier.lowercased()
        
        if let cached = cache[key], Date().timeIntervalSince(cached.createdAt) < cacheTTL {
            return cached.metadata
        }
        
        guard
            let encodedIdentifier = identifier.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = URL(string: "https://api.feed-the-beast.com/v1/modpacks/public/modpack/\(encodedIdentifier)")
        else {
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
            
            let payload = try JSONDecoder().decode(FTBModpackPayload.self, from: data)
            let latestVersion = Self.latestVersion(from: payload.versions)
            let javaVersion = Self.javaVersion(from: latestVersion?.targets)
            let modLoader = Self.modLoader(from: latestVersion?.targets)
            
            let metadata = FTBModpackMetadata(
                installs: payload.installs?.value,
                plays: payload.plays?.value,
                minimumRAMMB: latestVersion?.specs?.minimum?.value,
                recommendedRAMMB: latestVersion?.specs?.recommended?.value,
                javaVersion: javaVersion,
                modLoader: modLoader,
                lastUpdatedAt: Self.date(fromUnixTimestamp: payload.updated?.value),
                releasedAt: Self.date(fromUnixTimestamp: payload.released?.value)
            )
            
            cache[key] = CacheEntry(metadata: metadata, createdAt: Date())
            return metadata
        } catch {
            return nil
        }
    }
    
    nonisolated private static func identifier(for project: MinecraftCatalogProject) -> String? {
        let trimmedId = project.id.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedId.isEmpty == false, Int(trimmedId) != nil {
            return trimmedId
        }
        
        if let parsedId = project.feedTheBeastProjectId {
            return parsedId
        }
        
        if trimmedId.isEmpty == false {
            return trimmedId
        }
        
        return nil
    }
    
    nonisolated private static func latestVersion(from versions: [FTBModpackVersionPayload]?) -> FTBModpackVersionPayload? {
        guard let versions, versions.isEmpty == false else {
            return nil
        }
        
        return versions.max { lhs, rhs in
            let lhsUpdated = lhs.updated?.value ?? 0
            let rhsUpdated = rhs.updated?.value ?? 0
            
            if lhsUpdated == rhsUpdated {
                return (lhs.id?.value ?? 0) < (rhs.id?.value ?? 0)
            }
            
            return lhsUpdated < rhsUpdated
        }
    }
    
    nonisolated private static func javaVersion(from targets: [FTBModpackVersionTargetPayload]?) -> String? {
        guard let targets else {
            return nil
        }
        
        if let runtimeTarget = targets.first(where: { target in
            target.type?.lowercased() == "runtime" || target.name?.lowercased() == "java"
        }) {
            let trimmed = runtimeTarget.version?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            return trimmed.isEmpty ? nil : trimmed
        }
        
        return nil
    }
    
    nonisolated private static func modLoader(from targets: [FTBModpackVersionTargetPayload]?) -> String? {
        guard let targets else {
            return nil
        }
        
        guard let modLoaderTarget = targets.first(where: { target in
            target.type?.lowercased() == "modloader"
        }) else {
            return nil
        }
        
        let name = normalizedModLoaderName(modLoaderTarget.name)
        let version = trimmedValue(modLoaderTarget.version)
        
        if let name, let version {
            return "\(name) \(version)"
        }
        
        return name ?? version
    }
    
    nonisolated private static func normalizedModLoaderName(_ value: String?) -> String? {
        guard let value = trimmedValue(value) else {
            return nil
        }
        
        switch value.lowercased() {
        case "neoforge":
            return "NeoForge"
        case "forge":
            return "Forge"
        case "fabric":
            return "Fabric"
        case "quilt":
            return "Quilt"
        default:
            return value.capitalized
        }
    }
    
    nonisolated private static func trimmedValue(_ value: String?) -> String? {
        guard let value else {
            return nil
        }
        
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
    
    nonisolated private static func date(fromUnixTimestamp value: Int?) -> Date? {
        guard let value, value > 0 else {
            return nil
        }
        
        return Date(timeIntervalSince1970: TimeInterval(value))
    }
}

nonisolated private struct FTBModpackPayload: Decodable {
    let installs: FTBLossyInt?
    let plays: FTBLossyInt?
    let updated: FTBLossyInt?
    let released: FTBLossyInt?
    let versions: [FTBModpackVersionPayload]?
}

nonisolated private struct FTBModpackVersionPayload: Decodable {
    let id: FTBLossyInt?
    let updated: FTBLossyInt?
    let specs: FTBModpackVersionSpecsPayload?
    let targets: [FTBModpackVersionTargetPayload]?
}

nonisolated private struct FTBModpackVersionSpecsPayload: Decodable {
    let minimum: FTBLossyInt?
    let recommended: FTBLossyInt?
}

nonisolated private struct FTBModpackVersionTargetPayload: Decodable {
    let name: String?
    let type: String?
    let version: String?
}

nonisolated private struct FTBLossyInt: Decodable {
    let value: Int?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let intValue = try? container.decode(Int.self) {
            value = intValue
            return
        }
        
        if let stringValue = try? container.decode(String.self) {
            let trimmed = stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            value = Int(trimmed)
            return
        }
        
        if let doubleValue = try? container.decode(Double.self) {
            value = Int(doubleValue)
            return
        }
        
        value = nil
    }
}

private extension MinecraftCatalogProject {
    nonisolated var feedTheBeastProjectId: String? {
        let candidateURL = [externalURL, url]
            .compactMap {
                $0?.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            .first {
                $0.isEmpty == false
            }
        
        guard let candidateURL, let parsedURL = URL(string: candidateURL) else {
            return nil
        }
        
        let components = parsedURL.pathComponents.filter { $0 != "/" }
        let pathPart = Self.pathPart(from: components) ?? components.last
        
        guard let pathPart else {
            return nil
        }
        
        let prefix = String(pathPart.prefix { $0.isNumber })
        
        if prefix.isEmpty == false {
            return prefix
        }
        
        let trimmed = pathPart.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if Int(trimmed) != nil {
            return trimmed
        }
        
        return nil
    }
    
    nonisolated private static func pathPart(from components: [String]) -> String? {
        guard
            let modpacksIndex = components.firstIndex(where: { $0.lowercased() == "modpacks" }),
            components.indices.contains(modpacksIndex + 1)
        else {
            return nil
        }
        
        return components[modpacksIndex + 1]
    }
}
