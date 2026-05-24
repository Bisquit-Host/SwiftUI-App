import Foundation
import PteroNet

@Observable
final class ModpackInstallerVM {
    private let id: String
    private var serverId: String
    private var modpackSearchCache: [ModpackSearchCacheKey: ModpackSearchResult] = [:]
    
    init(_ id: String) {
        self.id = id
        serverId = id
    }
    
    private(set) var modpackInstallerAvailable = true
    
    private(set) var isLoadingModpacks = false
    private(set) var isInstallingModpack = false
    private(set) var modpacks: [MinecraftCatalogProject] = []
    private(set) var modpackVersions: [MinecraftCatalogVersion] = []
    private(set) var modpacksPagination = MinecraftPagination()
    private(set) var installedModpacks: [InstalledModpack] = []
    
    var mostRecentInstalledModpack: InstalledModpack? {
        installedModpacks.first
    }
    
    func setServerId(_ id: String) {
        guard !id.isEmpty else { return }
        
        if serverId.caseInsensitiveCompare(id) != .orderedSame {
            clearModpackSearchCache()
        }
        
        serverId = id
    }
    
    func fetchMinecraftModpacks(
        provider: ModpackProvider,
        page: Int = 1,
        pageSize: Int = 50,
        searchQuery: String = "",
        forceRefresh: Bool = false
    ) async {
        guard modpackInstallerAvailable else { return }
        let normalizedSearchQuery = trimmedSearchValue(searchQuery)
        
        let cacheKey = ModpackSearchCacheKey(
            provider: provider,
            page: page,
            pageSize: pageSize
        )
        
        if normalizedSearchQuery.isEmpty, !forceRefresh, let cachedResponse = modpackSearchCache[cacheKey] {
            applySearchResult(cachedResponse)
            return
        }
        
        isLoadingModpacks = true
        
        defer {
            isLoadingModpacks = false
        }
        
        do {
            let response = try await loadMinecraftModpacks(
                provider: provider,
                page: page,
                pageSize: pageSize,
                searchQuery: normalizedSearchQuery
            )
            let enrichedResponse = await enrichedModpackMetadata(response, provider: provider)
            
            applySearchResult(enrichedResponse)
            
            if normalizedSearchQuery.isEmpty {
                modpackSearchCache[cacheKey] = enrichedResponse
            }
        } catch {
            if isAddonMissing(error) {
                modpackInstallerAvailable = false
                modpacks = []
                modpackVersions = []
                installedModpacks = []
                clearModpackSearchCache()
                return
            }
            
            SystemAlert.error(error)
        }
    }
    
    func fetchMinecraftModpackVersions(provider: ModpackProvider, modpackId: String) async {
        guard modpackInstallerAvailable else {
            return
        }
        
        modpackVersions = []
        
        do {
            modpackVersions = try await loadMinecraftModpackVersions(
                provider: provider,
                modpackId: modpackId
            )
        } catch {
            if isAddonMissing(error) {
                modpackInstallerAvailable = false
                modpackVersions = []
                return
            }
            
            SystemAlert.error(error)
        }
    }
    
    func fetchFTBModpackVersionMods(modpackId: String, versionId: String) async -> [FTBModpackVersionMod] {
        guard modpackInstallerAvailable else {
            return []
        }
        
        do {
            return try await fetchFTBModpackVersionModsAPI(modpackId: modpackId, versionId: versionId)
        } catch {
            SystemAlert.error(error)
            return []
        }
    }
    
    @discardableResult
    func installMinecraftModpack(
        provider: ModpackProvider,
        modpackId: String,
        versionId: String,
        deleteServerFiles: Bool
    ) async -> Bool {
        guard modpackInstallerAvailable else {
            return false
        }
        
        isInstallingModpack = true
        defer {
            isInstallingModpack = false
        }
        
        do {
            try await requestMinecraftModpackInstall(
                provider: provider,
                modpackId: modpackId,
                versionId: versionId,
                deleteServerFiles: deleteServerFiles
            )
            clearModpackSearchCache()
            SystemAlert.done("Modpack install started")
            return true
        } catch {
            if isAddonMissing(error) {
                modpackInstallerAvailable = false
                modpackVersions = []
                return false
            }
            
            SystemAlert.error(error)
            return false
        }
    }
    
    func clearModpackSearchCache() {
        modpackSearchCache = [:]
    }
}

private extension ModpackInstallerVM {
    func applySearchResult(_ response: ModpackSearchResult) {
        modpacks = response.projects
        modpacksPagination = response.pagination
        installedModpacks = response.installedModpacks
        modpackInstallerAvailable = true
        prefetchMinecraftIcons(response.projects)
    }
    
    func trimmedSearchValue(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func loadMinecraftModpacks(
        provider: ModpackProvider,
        page: Int,
        pageSize: Int,
        searchQuery: String
    ) async throws -> ModpackSearchResult {
        let response: ModpackListResponse = try await fetchMinecraftModpacksAPI(
            apiKey: apiKey(),
            serverId: serverId,
            fallbackServerId: id,
            provider: provider.rawValue,
            page: page,
            pageSize: pageSize,
            searchQuery: searchQuery
        )
        
        return ModpackSearchResult(
            projects: response.data.map(\.model),
            pagination: response.meta.pagination.model,
            installedModpacks: response.meta.installedModpacks.map(\.model)
        )
    }
    
    func loadMinecraftModpackVersions(provider: ModpackProvider, modpackId: String) async throws -> [MinecraftCatalogVersion] {
        let response: [ModpackProjectVersionPayload] = try await fetchMinecraftModpackVersionsAPI(
            apiKey: apiKey(),
            serverId: serverId,
            fallbackServerId: id,
            provider: provider.rawValue,
            modpackId: modpackId
        )
        
        return response.map(\.model)
    }
    
    func requestMinecraftModpackInstall(
        provider: ModpackProvider,
        modpackId: String,
        versionId: String,
        deleteServerFiles: Bool
    ) async throws {
        
        let payload = ModpackInstallPayload(
            provider: provider.rawValue,
            modpackId: modpackId,
            modpackVersionId: versionId,
            deleteServerFiles: deleteServerFiles
        )
        
        try await installMinecraftModpackAPI(
            apiKey: apiKey(),
            serverId: serverId,
            fallbackServerId: id,
            body: payload
        )
    }
    
    func fetchFTBModpackVersionModsAPI(modpackId: String, versionId: String) async throws -> [FTBModpackVersionMod] {
        let data = try await fetchFTBModpackVersionModsDataAPI(modpackId: modpackId, versionId: versionId)
        let payload = try JSONDecoder().decode(FTBModpackVersionDetailsPayload.self, from: data)
        
        return payload.files
            .compactMap(\.model)
            .sorted {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
    }
    
    func isAddonMissing(_ error: Error) -> Bool {
        isMissingMinecraftInstallerError(error)
    }
    
    func apiKey() throws -> String {
        guard let apiKey = Keychain.load(key: "selectedApiKey") else {
            throw MinecraftInstallerRequestError.noApiKey
        }
        
        return apiKey
    }
    
    func prefetchMinecraftIcons(_ projects: [MinecraftCatalogProject]) {
        let iconURLs = projects.compactMap(\.iconURL)
        guard !iconURLs.isEmpty else { return }
        
        Prefetcher.prefetchImages(iconURLs)
    }
    
    func enrichedModpackMetadata(
        _ response: ModpackSearchResult,
        provider: ModpackProvider
    ) async -> ModpackSearchResult {
        let projects: [MinecraftCatalogProject]
        
        switch provider {
        case .modrinth:
            let statsByProject = await ModrinthProjectStatsService.shared.fetchStats(for: response.projects)
            guard statsByProject.isEmpty == false else {
                return response
            }
            
            projects = response.projects.map { project in
                guard let stats = statsByProject[project.id] else {
                    return project
                }
                
                return project
                    .replacingStats(likes: stats.likes, downloads: stats.downloads)
                    .replacingTimeline(lastUpdatedAt: stats.lastUpdatedAt, releasedAt: stats.releasedAt)
            }
        case .curseforge:
            let statsByProject = await CurseForgeProjStatsService.shared.fetchStats(
                for: response.projects,
                category: .modpacks
            )
            guard statsByProject.isEmpty == false else {
                return response
            }
            
            projects = response.projects.map { project in
                guard let stats = statsByProject[project.id] else {
                    return project
                }
                
                return project.replacingStats(likes: nil, downloads: stats.downloads)
            }
        case .feedthebeast:
            let metadataByProject = await FTBModpackMetadataService.shared.fetchMetadata(for: response.projects)
            guard metadataByProject.isEmpty == false else {
                return response
            }
            
            projects = response.projects.map { project in
                guard let metadata = metadataByProject[project.id] else {
                    return project
                }
                
                return project.replacingFTBMetadata(
                    installs: metadata.installs,
                    plays: metadata.plays,
                    minimumRAMMB: metadata.minimumRAMMB,
                    recommendedRAMMB: metadata.recommendedRAMMB,
                    javaVersion: metadata.javaVersion,
                    modLoader: metadata.modLoader,
                    lastUpdatedAt: metadata.lastUpdatedAt,
                    releasedAt: metadata.releasedAt
                )
            }
        case .atlauncher, .technic, .voidswrath:
            return response
        }
        
        return ModpackSearchResult(
            projects: projects,
            pagination: response.pagination,
            installedModpacks: response.installedModpacks
        )
    }
}

private struct ModpackSearchResult {
    let projects: [MinecraftCatalogProject]
    let pagination: MinecraftPagination
    let installedModpacks: [InstalledModpack]
}

private struct ModpackSearchCacheKey: Hashable {
    let provider: ModpackProvider
    let page: Int
    let pageSize: Int
}

private struct ModpackLossyString: Decodable {
    let value: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let stringValue = try? container.decode(String.self) {
            value = stringValue
            return
        }
        
        if let intValue = try? container.decode(Int.self) {
            value = String(intValue)
            return
        }
        
        if let doubleValue = try? container.decode(Double.self) {
            value = String(doubleValue)
            return
        }
        
        value = ""
    }
}

private struct ModpackLossyInt: Decodable {
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

private struct ModpackLossyBool: Decodable {
    let value: Bool?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let boolValue = try? container.decode(Bool.self) {
            value = boolValue
            return
        }
        
        if let intValue = try? container.decode(Int.self) {
            value = intValue != 0
            return
        }
        
        if let stringValue = try? container.decode(String.self) {
            let trimmed = stringValue.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            
            switch trimmed {
            case "true", "1", "yes":
                value = true
                
            case "false", "0", "no":
                value = false
                
            default:
                value = nil
            }
            
            return
        }
        
        value = nil
    }
}

private struct ModpackListResponse: Decodable {
    let data: [ModpackProjectPayload]
    let meta: ModpackMetaPayload
}

private struct ModpackMetaPayload: Decodable {
    let pagination: ModpackPaginationPayload
    let installedModpacks: [ModpackInstalledModpackPayload]
    
    private enum CodingKeys: String, CodingKey {
        case pagination, installedModpacks, installedModpack
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        pagination = try container.decode(ModpackPaginationPayload.self, forKey: .pagination)
        
        if let list = try container.decodeIfPresent([ModpackInstalledModpackPayload].self, forKey: .installedModpacks) {
            installedModpacks = list
            return
        }
        
        if let single = try container.decodeIfPresent(ModpackInstalledModpackPayload.self, forKey: .installedModpack) {
            installedModpacks = [single]
            return
        }
        
        installedModpacks = []
    }
}

private struct ModpackPaginationPayload: Decodable {
    let total: Int
    let currentPage: Int
    let totalPages: Int
    
    var model: MinecraftPagination {
        MinecraftPagination(currentPage: currentPage, totalPages: totalPages, total: total)
    }
}

private struct ModpackProjectPayload: Decodable {
    let id: ModpackLossyString
    let name: String
    let shortDescription: String?
    let description: String?
    let url: String?
    let iconUrl: String?
    let externalUrl: String?
    let likes: ModpackLossyInt?
    let downloads: ModpackLossyInt?
    let installs: ModpackLossyInt?
    let plays: ModpackLossyInt?
    let updated: ModpackLossyInt?
    let released: ModpackLossyInt?
    
    private enum CodingKeys: String, CodingKey {
        case id, name, shortDescription, description, url, iconUrl, externalUrl, likes, downloads, follows, followers, installs, plays, updated, released
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(ModpackLossyString.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        shortDescription = try container.decodeIfPresent(String.self, forKey: .shortDescription)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        url = try container.decodeIfPresent(String.self, forKey: .url)
        iconUrl = try container.decodeIfPresent(String.self, forKey: .iconUrl)
        externalUrl = try container.decodeIfPresent(String.self, forKey: .externalUrl)
        
        likes = try container.decodeIfPresent(ModpackLossyInt.self, forKey: .likes)
        ?? container.decodeIfPresent(ModpackLossyInt.self, forKey: .follows)
        ?? container.decodeIfPresent(ModpackLossyInt.self, forKey: .followers)
        
        downloads = try container.decodeIfPresent(ModpackLossyInt.self, forKey: .downloads)
        installs = try container.decodeIfPresent(ModpackLossyInt.self, forKey: .installs)
        plays = try container.decodeIfPresent(ModpackLossyInt.self, forKey: .plays)
        updated = try container.decodeIfPresent(ModpackLossyInt.self, forKey: .updated)
        released = try container.decodeIfPresent(ModpackLossyInt.self, forKey: .released)
    }
    
    var model: MinecraftCatalogProject {
        MinecraftCatalogProject(
            id: id.value,
            name: name,
            description: shortDescription ?? description ?? "",
            url: url,
            iconURLString: iconUrl,
            externalURL: externalUrl,
            likes: likes?.value,
            downloads: downloads?.value,
            installs: installs?.value,
            plays: plays?.value,
            lastUpdatedAt: Self.date(fromUnixTimestamp: updated?.value),
            releasedAt: Self.date(fromUnixTimestamp: released?.value)
        )
    }
    
    private static func date(fromUnixTimestamp value: Int?) -> Date? {
        guard let value, value > 0 else {
            return nil
        }
        
        return Date(timeIntervalSince1970: TimeInterval(value))
    }
}

private struct ModpackInstalledModpackPayload: Decodable {
    let id: ModpackLossyString
    let provider: String
    let name: String
    let description: String?
    let url: String?
    let iconUrl: String?
    
    var model: InstalledModpack {
        InstalledModpack(
            id: id.value,
            provider: provider,
            name: name,
            description: description ?? "",
            url: url,
            iconURLString: iconUrl
        )
    }
}

private struct ModpackProjectVersionPayload: Decodable {
    let id: ModpackLossyString
    let name: String?
    
    var model: MinecraftCatalogVersion {
        MinecraftCatalogVersion(
            id: id.value,
            name: name ?? id.value
        )
    }
}

private struct FTBModpackVersionDetailsPayload: Decodable {
    let files: [FTBModpackVersionFilePayload]
    
    private enum CodingKeys: String, CodingKey {
        case files
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        files = try container.decodeIfPresent([FTBModpackVersionFilePayload].self, forKey: .files) ?? []
    }
}

private struct FTBModpackVersionFilePayload: Decodable {
    let id: ModpackLossyString?
    let name: String?
    let url: String?
    let type: String?
    let sha1: String?
    let hashes: FTBModpackVersionFileHashesPayload?
    let clientOnly: ModpackLossyBool?
    let serverOnly: ModpackLossyBool?
    
    private enum CodingKeys: String, CodingKey {
        case id, name, url, type, sha1, hashes
        case clientOnly = "clientonly"
        case serverOnly = "serveronly"
    }
    
    var model: FTBModpackVersionMod? {
        guard type?.lowercased() == "mod" else {
            return nil
        }
        
        let trimmedName = (name ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard trimmedName.isEmpty == false else {
            return nil
        }
        
        let trimmedURL = url?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        let normalizedURL = (trimmedURL?.isEmpty == false) ? trimmedURL : nil
        let normalizedId = id?.value.trimmingCharacters(in: .whitespacesAndNewlines)
        let resolvedSHA1 = sha1?.trimmingCharacters(in: .whitespacesAndNewlines)
            ?? hashes?.sha1?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return FTBModpackVersionMod(
            id: [normalizedId, trimmedName]
                .compactMap { $0 }
                .joined(separator: "/"),
            name: trimmedName,
            sourceURLString: normalizedURL,
            sha1: resolvedSHA1,
            clientOnly: clientOnly?.value ?? false,
            serverOnly: serverOnly?.value ?? false
        )
    }
}

private struct FTBModpackVersionFileHashesPayload: Decodable {
    let sha1: String?
}

nonisolated private struct ModpackInstallPayload: Encodable, Sendable {
    let provider: String
    let modpackId: String
    let modpackVersionId: String
    let deleteServerFiles: Bool
    
    private enum CodingKeys: String, CodingKey {
        case provider,
             modpackId = "modpack_id",
             modpackVersionId = "modpack_version_id",
             deleteServerFiles = "delete_server_files"
    }
}
