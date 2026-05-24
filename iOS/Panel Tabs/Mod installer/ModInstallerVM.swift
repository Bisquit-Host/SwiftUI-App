import Foundation
import PteroNet

@Observable
final class ModInstallerVM {
    private let id: String
    private var serverId: String
    private var modSearchCache: [ModSearchCacheKey: ModCatalogSearchResult] = [:]

    init(_ id: String) {
        self.id = id
        serverId = id
    }

    private(set) var modManagerAvailable = true

    private(set) var isLoadingMods = false
    private(set) var isInstallingMod = false
    private(set) var mods: [MinecraftCatalogProject] = []
    private(set) var modVersions: [MinecraftCatalogVersion] = []
    private(set) var installedMods: [MinecraftInstalledProject] = []
    private(set) var modsPagination = MinecraftPagination()
    private(set) var versionOptions: [String] = []
    private(set) var modLoaderOptions: [String] = []

    func setServerId(_ id: String) {
        guard !id.isEmpty else {
            return
        }

        if serverId.caseInsensitiveCompare(id) != .orderedSame {
            clearModSearchCache()
        }

        serverId = id
    }

    func fetchMinecraftMods(
        provider: ModManagerProvider,
        page: Int = 1,
        pageSize: Int = 50,
        searchQuery: String = "",
        version: String = "",
        modLoader: String = "",
        forceRefresh: Bool = false
    ) async {
        guard modManagerAvailable else {
            return
        }

        let normalizedSearchQuery = trimmedSearchValue(searchQuery)
        let normalizedMinecraftVersion = trimmedSearchValue(version)
        let normalizedModLoader = trimmedSearchValue(modLoader)
        let cacheKey = ModSearchCacheKey(
            provider: provider,
            page: page,
            pageSize: pageSize,
            version: normalizedMinecraftVersion,
            modLoader: normalizedModLoader
        )

        if normalizedSearchQuery.isEmpty,
           !forceRefresh,
           let cachedResponse = modSearchCache[cacheKey] {
            applySearchResult(cachedResponse)
            return
        }

        isLoadingMods = true
        defer {
            isLoadingMods = false
        }

        do {
            async let responseTask = fetchMinecraftModsAPI(
                provider: provider,
                page: page,
                pageSize: pageSize,
                searchQuery: normalizedSearchQuery,
                version: normalizedMinecraftVersion,
                modLoader: normalizedModLoader
            )
            async let manifestVersionsTask = fetchMinecraftVersionsFromManifest()

            let response = try await responseTask
            let enrichedResponse = await enrichedModrinthStats(response, provider: provider)
            applySearchResult(enrichedResponse, manifestVersions: await manifestVersionsTask)

            if normalizedSearchQuery.isEmpty {
                modSearchCache[cacheKey] = enrichedResponse
            }
        } catch {
            if isAddonMissing(error) {
                modManagerAvailable = false
                mods = []
                modVersions = []
                installedMods = []
                versionOptions = []
                modLoaderOptions = []
                clearModSearchCache()
                return
            }

            SystemAlert.error(error)
        }
    }

    func fetchMinecraftModVersions(
        provider: ModManagerProvider,
        modId: String,
        modLoader: String = "",
        version: String = ""
    ) async {
        guard modManagerAvailable else {
            return
        }

        modVersions = []

        do {
            modVersions = try await fetchMinecraftModVersionsAPI(
                provider: provider,
                modId: modId,
                modLoader: modLoader,
                version: version
            )
        } catch {
            if isAddonMissing(error) {
                modManagerAvailable = false
                modVersions = []
                return
            }

            SystemAlert.error(error)
        }
    }

    @discardableResult
    func installMinecraftMod(
        provider: ModManagerProvider,
        modId: String,
        versionId: String
    ) async -> Bool {
        guard modManagerAvailable else {
            return false
        }

        isInstallingMod = true
        defer {
            isInstallingMod = false
        }

        do {
            try await installMinecraftModAPI(
                provider: provider,
                modId: modId,
                versionId: versionId
            )
            await fetchInstalledMinecraftMods()
            SystemAlert.done("Mod installed")
            return true
        } catch {
            if isAddonMissing(error) {
                modManagerAvailable = false
                modVersions = []
                return false
            }

            SystemAlert.error(error)
            return false
        }
    }

    func fetchInstalledMinecraftMods() async {
        guard modManagerAvailable else {
            return
        }

        do {
            installedMods = try await fetchInstalledMinecraftModsAPI()
            modManagerAvailable = true
        } catch {
            if isAddonMissing(error) {
                modManagerAvailable = false
                installedMods = []
                return
            }

            SystemAlert.error(error)
        }
    }

    func clearModSearchCache() {
        modSearchCache = [:]
    }
}

private extension ModInstallerVM {
    func applySearchResult(_ response: ModCatalogSearchResult, manifestVersions: [String]? = nil) {
        mods = response.projects
        modsPagination = response.pagination

        let resolvedManifestVersions: [String]
        if let manifestVersions {
            resolvedManifestVersions = manifestVersions
        } else {
            resolvedManifestVersions = []
        }

        versionOptions = resolvedManifestVersions.isEmpty
            ? normalizedOptions(response.versions)
            : resolvedManifestVersions
        modLoaderOptions = normalizedOptions(response.modLoaders)
        modManagerAvailable = true
        prefetchMinecraftIcons(response.projects)
    }

    func trimmedSearchValue(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func fetchMinecraftModsAPI(
        provider: ModManagerProvider,
        page: Int,
        pageSize: Int,
        searchQuery: String,
        version: String,
        modLoader: String
    ) async throws -> ModCatalogSearchResult {
        let response: ModProjectsListResponse = try await PteroNet.fetchMinecraftModsAPI(
            apiKey: apiKey(),
            serverId: serverId,
            fallbackServerId: id,
            provider: provider.rawValue,
            page: page,
            pageSize: pageSize,
            searchQuery: searchQuery,
            version: version,
            modLoader: modLoader
        )

        return ModCatalogSearchResult(
            projects: response.data.map(\.model),
            pagination: response.meta.pagination.model,
            versions: response.meta.versions,
            modLoaders: response.meta.modLoaders
        )
    }

    func fetchMinecraftModVersionsAPI(
        provider: ModManagerProvider,
        modId: String,
        modLoader: String,
        version: String
    ) async throws -> [MinecraftCatalogVersion] {
        let response: [ModProjectVersionPayload] = try await PteroNet.fetchMinecraftModVersionsAPI(
            apiKey: apiKey(),
            serverId: serverId,
            fallbackServerId: id,
            provider: provider.rawValue,
            modId: modId,
            modLoader: modLoader,
            version: version
        )

        return response.map(\.model)
    }

    func installMinecraftModAPI(
        provider: ModManagerProvider,
        modId: String,
        versionId: String
    ) async throws {
        let payload = MinecraftModInstallPayload(
            provider: provider.rawValue,
            modId: modId,
            versionId: versionId
        )

        try await PteroNet.installMinecraftModAPI(
            apiKey: apiKey(),
            serverId: serverId,
            fallbackServerId: id,
            body: payload
        )
    }

    func fetchInstalledMinecraftModsAPI() async throws -> [MinecraftInstalledProject] {
        let response: ModInstalledProjectsPayload = try await PteroNet.fetchInstalledMinecraftModsAPI(
            apiKey: apiKey(),
            serverId: serverId,
            fallbackServerId: id
        )

        return response.projects
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
        guard !iconURLs.isEmpty else {
            return
        }

        Prefetcher.prefetchImages(iconURLs)
    }
    
    func normalizedOptions(_ values: [String]) -> [String] {
        var output: [String] = []
        var seen = Set<String>()
        
        for value in values {
            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty, seen.insert(trimmed).inserted else {
                continue
            }
            
            output.append(trimmed)
        }
        
        return output
    }

    func fetchMinecraftVersionsFromManifest() async -> [String] {
        do {
            return try await PteroNet.fetchMinecraftReleaseVersionsFromManifestAPI()
        } catch {
            return []
        }
    }

    func enrichedModrinthStats(
        _ response: ModCatalogSearchResult,
        provider: ModManagerProvider
    ) async -> ModCatalogSearchResult {
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
                category: .mcMods
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
        }

        return ModCatalogSearchResult(
            projects: projects,
            pagination: response.pagination,
            versions: response.versions,
            modLoaders: response.modLoaders
        )
    }
}

private struct ModCatalogSearchResult {
    let projects: [MinecraftCatalogProject]
    let pagination: MinecraftPagination
    let versions: [String]
    let modLoaders: [String]
}

private struct ModSearchCacheKey: Hashable {
    let provider: ModManagerProvider
    let page: Int
    let pageSize: Int
    let version: String
    let modLoader: String
}

private struct ModLossyString: Decodable {
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

private struct ModLossyInt: Decodable {
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

private struct ModProjectsListResponse: Decodable {
    let data: [ModProjectPayload]
    let meta: ModProjectsMetaPayload
}

private struct ModProjectsMetaPayload: Decodable {
    let pagination: ModPaginationPayload
    let versions: [String]
    let modLoaders: [String]
    
    private enum CodingKeys: String, CodingKey {
        case pagination
        case versions
        case minecraftVersionsLegacy = "minecraftVersions"
        case minecraftVersionsSnake = "minecraft_versions"
        case modLoaders
        case modLoadersSnake = "mod_loaders"
        case filters
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        pagination = try container.decode(ModPaginationPayload.self, forKey: .pagination)
        
        let directMinecraftVersions = try container.decodeIfPresent([String].self, forKey: .versions)
            ?? container.decodeIfPresent([String].self, forKey: .minecraftVersionsLegacy)
            ?? container.decodeIfPresent([String].self, forKey: .minecraftVersionsSnake)
            ?? []
        
        let directModLoaders = try container.decodeIfPresent([String].self, forKey: .modLoaders)
            ?? container.decodeIfPresent([String].self, forKey: .modLoadersSnake)
            ?? []
        
        let filterPayload = try container.decodeIfPresent(ModFilterOptionsPayload.self, forKey: .filters)
        
        versions = directMinecraftVersions.isEmpty ? (filterPayload?.versions ?? []) : directMinecraftVersions
        modLoaders = directModLoaders.isEmpty ? (filterPayload?.modLoaders ?? []) : directModLoaders
    }
}

private struct ModFilterOptionsPayload: Decodable {
    let versions: [String]
    let modLoaders: [String]
    
    private enum CodingKeys: String, CodingKey {
        case versions
        case minecraftVersionsLegacy = "minecraftVersions"
        case minecraftVersionsSnake = "minecraft_versions"
        case modLoaders
        case modLoadersSnake = "mod_loaders"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        versions = try container.decodeIfPresent([String].self, forKey: .versions)
            ?? container.decodeIfPresent([String].self, forKey: .minecraftVersionsLegacy)
            ?? container.decodeIfPresent([String].self, forKey: .minecraftVersionsSnake)
            ?? []
        
        modLoaders = try container.decodeIfPresent([String].self, forKey: .modLoaders)
            ?? container.decodeIfPresent([String].self, forKey: .modLoadersSnake)
            ?? []
    }
}

private struct ModPaginationPayload: Decodable {
    let total: Int
    let currentPage: Int
    let totalPages: Int

    var model: MinecraftPagination {
        MinecraftPagination(
            currentPage: currentPage,
            totalPages: totalPages,
            total: total
        )
    }
}

private struct ModProjectPayload: Decodable {
    let id: ModLossyString
    let name: String
    let shortDescription: String?
    let description: String?
    let url: String?
    let iconUrl: String?
    let externalUrl: String?
    let likes: ModLossyInt?
    let downloads: ModLossyInt?

    private enum CodingKeys: String, CodingKey {
        case id, name, shortDescription, description, url, iconUrl, externalUrl, likes, downloads, follows, followers
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(ModLossyString.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        shortDescription = try container.decodeIfPresent(String.self, forKey: .shortDescription)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        url = try container.decodeIfPresent(String.self, forKey: .url)
        iconUrl = try container.decodeIfPresent(String.self, forKey: .iconUrl)
        externalUrl = try container.decodeIfPresent(String.self, forKey: .externalUrl)

        likes = try container.decodeIfPresent(ModLossyInt.self, forKey: .likes)
            ?? container.decodeIfPresent(ModLossyInt.self, forKey: .follows)
            ?? container.decodeIfPresent(ModLossyInt.self, forKey: .followers)

        downloads = try container.decodeIfPresent(ModLossyInt.self, forKey: .downloads)
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
            downloads: downloads?.value
        )
    }
}

private struct ModProjectVersionPayload: Decodable {
    let id: ModLossyString
    let name: String?

    var model: MinecraftCatalogVersion {
        MinecraftCatalogVersion(
            id: id.value,
            name: name ?? id.value
        )
    }
}

private struct ModInstalledProjectsPayload: Decodable {
    let projects: [MinecraftInstalledProject]

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let projects = try? container.decode([ModInstalledProjectPayload].self) {
            self.projects = projects.map(\.model)
            return
        }

        if let identified = try? container.decode(ModInstalledProjectsIdentifiedPayload.self) {
            self.projects = identified.identified.map(\.model)
            return
        }

        projects = []
    }
}

private struct ModInstalledProjectsIdentifiedPayload: Decodable {
    let identified: [ModInstalledProjectPayload]
}

private struct ModInstalledProjectPayload: Decodable {
    let path: String
    let provider: String?
    let projectId: String?
    let projectName: String?
    let versionId: String?
    let versionName: String?
    let iconUrl: String?
    let update: ModInstalledProjectUpdatePayload?

    var model: MinecraftInstalledProject {
        MinecraftInstalledProject(
            path: path,
            provider: provider,
            projectId: projectId,
            projectName: projectName,
            versionId: versionId,
            versionName: versionName,
            iconURLString: iconUrl,
            update: update?.model
        )
    }
}

private struct ModInstalledProjectUpdatePayload: Decodable {
    let id: ModLossyString
    let name: String

    var model: MinecraftProjectUpdate {
        MinecraftProjectUpdate(id: id.value, name: name)
    }
}

private struct MinecraftModInstallPayload: Encodable {
    let provider: String
    let modId: String
    let versionId: String
}
