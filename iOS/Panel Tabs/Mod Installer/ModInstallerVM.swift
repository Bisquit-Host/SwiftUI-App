import Foundation
import Calagopus

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
        let normalizedPage = normalizedPageValue(page)
        let normalizedPageSize = normalizedPageSize(pageSize)
        let cacheKey = ModSearchCacheKey(
            provider: provider,
            page: normalizedPage,
            pageSize: normalizedPageSize,
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
            async let responseTask = loadMinecraftMods(
                provider: provider,
                page: normalizedPage,
                pageSize: normalizedPageSize,
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
            modVersions = try await loadMinecraftModVersions(
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
        versionId: String,
        replacingInstalledPath: String? = nil
    ) async -> Bool {
        guard modManagerAvailable else {
            return false
        }
        
        isInstallingMod = true
        defer {
            isInstallingMod = false
        }
        
        do {
            if let replacingInstalledPath {
                try await deleteInstalledMinecraftMod(path: replacingInstalledPath)
            }
            
            try await requestMinecraftModInstall(
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
            installedMods = try await loadInstalledMinecraftMods()
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
    
    func loadMinecraftMods(
        provider: ModManagerProvider,
        page: Int,
        pageSize: Int,
        searchQuery: String,
        version: String,
        modLoader: String
    ) async throws -> ModCatalogSearchResult {
        let response: ModProjectsListResponse = try await requestMinecraftMod(
            path: "minecraft/mods",
            query: normalizedQueryItems([
                URLQueryItem(name: "provider", value: provider.rawValue),
                URLQueryItem(name: "per_page", value: String(normalizedPageSize(pageSize))),
                URLQueryItem(name: "page", value: String(normalizedPageValue(page))),
                URLQueryItem(name: "search_query", value: searchQuery),
                URLQueryItem(name: "minecraft_version", value: version),
                URLQueryItem(name: "mod_loader", value: modLoader)
            ])
        )
        
        return ModCatalogSearchResult(
            projects: response.data.map(\.model),
            pagination: response.meta.pagination.model,
            versions: response.meta.versions,
            modLoaders: response.meta.modLoaders
        )
    }
    
    func loadMinecraftModVersions(
        provider: ModManagerProvider,
        modId: String,
        modLoader: String,
        version: String
    ) async throws -> [MinecraftCatalogVersion] {
        let response: [ModProjectVersionPayload] = try await requestMinecraftMod(
            path: "minecraft/mods/versions",
            query: normalizedQueryItems([
                URLQueryItem(name: "provider", value: provider.rawValue),
                URLQueryItem(name: "mod_id", value: modId),
                URLQueryItem(name: "mod_loader", value: modLoader),
                URLQueryItem(name: "minecraft_version", value: version)
            ])
        )
        
        return response.map(\.model)
    }
    
    func requestMinecraftModInstall(
        provider: ModManagerProvider,
        modId: String,
        versionId: String
    ) async throws {
        let payload = MinecraftModInstallPayload(
            provider: provider.rawValue,
            modId: modId,
            versionId: versionId
        )
        
        try await requestMinecraftModPost(
            path: "minecraft/mods/install",
            body: payload,
            timeout: 60 * 60
        )
    }
    
    func loadInstalledMinecraftMods() async throws -> [MinecraftInstalledProject] {
        let response: ModInstalledProjectsPayload = try await requestMinecraftMod(path: "minecraft/mods/installed")
        
        return response.projects
    }
    
    func deleteInstalledMinecraftMod(path: String) async throws {
        let trimmedPath = path.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedPath.isEmpty else {
            return
        }
        
        let candidates = serverCandidates()
        let client = try CalagopusNet.client()
        
        for (index, server) in candidates.enumerated() {
            do {
                try await client.deleteFiles(server: server, root: "/", files: [trimmedPath])
                return
            } catch {
                let isLast = index == candidates.index(before: candidates.endIndex)
                
                if !isLast, shouldRetryWithNextServerCandidate(after: error) {
                    continue
                }
                
                throw error
            }
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
    
    func requestMinecraftMod<Response: Decodable>(
        path: String,
        query: [URLQueryItem] = [],
        method: HTTPMethod = .get,
        body: (any Encodable & Sendable)? = nil,
        timeout: TimeInterval = 60
    ) async throws -> Response {
        try await requestMinecraftMod(
            path: path,
            query: query,
            method: method,
            body: body,
            timeout: timeout
        ) { data, _ in
            try BigAssDecoder.decode(Response.self, from: data)
        }
    }
    
    func requestMinecraftModPost(
        path: String,
        body: any Encodable & Sendable,
        timeout: TimeInterval = 60
    ) async throws {
        try await requestMinecraftMod(path: path, method: .post, body: body, timeout: timeout) { _, _ in () }
    }
    
    func requestMinecraftMod<Response>(
        path: String,
        query: [URLQueryItem] = [],
        method: HTTPMethod = .get,
        body: (any Encodable & Sendable)? = nil,
        timeout: TimeInterval = 60,
        decode: (Data, URLResponse) throws -> Response
    ) async throws -> Response {
        let apiKey = try apiKey()
        let candidates = serverCandidates()
        
        for (index, server) in candidates.enumerated() {
            do {
                let requestPath = "client/servers/\(server)/\(path)\(querySuffix(query))"
                guard var request = URLRequest(httpMethod: method, path: requestPath, body: body, apiKey: apiKey) else {
                    throw URLError(.badURL)
                }
                
                request.timeoutInterval = timeout
                let (data, response) = try await URLSession.shared.data(for: request)
                try validateMinecraftModResponse(data: data, response: response)
                
                return try decode(data, response)
            } catch {
                let isLast = index == candidates.index(before: candidates.endIndex)
                
                if !isLast, shouldRetryWithNextServerCandidate(after: error) {
                    continue
                }
                
                throw error
            }
        }
        
        throw MinecraftInstallerRequestError.emptyResponse
    }
    
    func validateMinecraftModResponse(data: Data, response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw MinecraftInstallerRequestError.emptyResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let apiError = try? BigAssDecoder.decode(CalagopusAPIError.self, from: data)
            throw CalagopusError.httpStatus(httpResponse.statusCode, data, apiError)
        }
    }
    
    func serverCandidates() -> [String] {
        guard serverId.caseInsensitiveCompare(id) != .orderedSame else {
            return [serverId]
        }
        
        return [serverId, id]
    }
    
    func shouldRetryWithNextServerCandidate(after error: Error) -> Bool {
        if isAddonMissing(error) {
            return true
        }
        
        if case MinecraftInstallerRequestError.badStatusCode(400) = error {
            return true
        }
        
        return false
    }
    
    func normalizedPageValue(_ page: Int) -> Int {
        min(65_535, max(1, page))
    }
    
    func normalizedPageSize(_ pageSize: Int) -> Int {
        min(50, max(1, pageSize))
    }
    
    func normalizedQueryItems(_ queryItems: [URLQueryItem]) -> [URLQueryItem] {
        queryItems.filter {
            guard let value = $0.value?.trimmingCharacters(in: .whitespacesAndNewlines) else {
                return false
            }
            
            return value.isEmpty == false
        }
    }
    
    func querySuffix(_ query: [URLQueryItem]) -> String {
        guard !query.isEmpty else {
            return ""
        }
        
        var components = URLComponents()
        components.queryItems = query
        
        guard let encodedQuery = components.percentEncodedQuery else {
            return ""
        }
        
        return "?\(encodedQuery)"
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
            return try await fetchMinecraftReleaseVersionsFromManifestAPI()
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

nonisolated private struct ModLossyString: Decodable {
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

nonisolated private struct ModLossyInt: Decodable {
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

nonisolated private struct ModProjectsListResponse: Decodable {
    let data: [ModProjectPayload]
    let meta: ModProjectsMetaPayload
    
    private enum CodingKeys: String, CodingKey {
        case data, meta
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let data = try container.decodeIfPresent([ModProjectPayload].self, forKey: .data),
           let meta = try container.decodeIfPresent(ModProjectsMetaPayload.self, forKey: .meta) {
            self.data = data
            self.meta = meta
            return
        }
        
        let page = try ModPaginatedProjectsPayload(from: decoder)
        data = page.data
        meta = ModProjectsMetaPayload(pagination: page.pagination, versions: [], modLoaders: [])
    }
}

nonisolated private struct ModProjectsMetaPayload: Decodable {
    let pagination: ModPaginationPayload
    let versions: [String]
    let modLoaders: [String]
    
    init(pagination: ModPaginationPayload, versions: [String], modLoaders: [String]) {
        self.pagination = pagination
        self.versions = versions
        self.modLoaders = modLoaders
    }
    
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

nonisolated private struct ModPaginatedProjectsPayload: Decodable {
    let total: Int
    let perPage: Int
    let page: Int
    let data: [ModProjectPayload]
    
    private enum CodingKeys: String, CodingKey {
        case total, perPage, page, currentPage, data
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        total = try container.decodeIfPresent(ModLossyInt.self, forKey: .total)?.value ?? 0
        perPage = try container.decodeIfPresent(ModLossyInt.self, forKey: .perPage)?.value ?? 50
        page = try container.decodeIfPresent(ModLossyInt.self, forKey: .page)?.value
        ?? container.decodeIfPresent(ModLossyInt.self, forKey: .currentPage)?.value
        ?? 1
        data = try container.decodeIfPresent([ModProjectPayload].self, forKey: .data) ?? []
    }
    
    var pagination: ModPaginationPayload {
        ModPaginationPayload(total: total, currentPage: page, totalPages: max(1, Int(ceil(Double(total) / Double(max(1, perPage))))))
    }
}

nonisolated private struct ModFilterOptionsPayload: Decodable {
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

nonisolated private struct ModPaginationPayload: Decodable {
    let total: Int
    let currentPage: Int
    let totalPages: Int
    
    private enum CodingKeys: String, CodingKey {
        case total, currentPage, page, totalPages, lastPage, perPage
    }
    
    init(total: Int, currentPage: Int, totalPages: Int) {
        self.total = total
        self.currentPage = currentPage
        self.totalPages = totalPages
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let perPage = try container.decodeIfPresent(ModLossyInt.self, forKey: .perPage)?.value
        
        total = try container.decodeIfPresent(ModLossyInt.self, forKey: .total)?.value ?? 0
        currentPage = try container.decodeIfPresent(ModLossyInt.self, forKey: .currentPage)?.value
        ?? container.decodeIfPresent(ModLossyInt.self, forKey: .page)?.value
        ?? 1
        totalPages = try container.decodeIfPresent(ModLossyInt.self, forKey: .totalPages)?.value
        ?? container.decodeIfPresent(ModLossyInt.self, forKey: .lastPage)?.value
        ?? max(1, Int(ceil(Double(total) / Double(max(1, perPage ?? 50)))))
    }
    
    var model: MinecraftPagination {
        MinecraftPagination(
            currentPage: currentPage,
            totalPages: totalPages,
            total: total
        )
    }
}

nonisolated private struct ModProjectPayload: Decodable {
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

nonisolated private struct ModProjectVersionPayload: Decodable {
    let id: ModLossyString
    let name: String?
    
    var model: MinecraftCatalogVersion {
        MinecraftCatalogVersion(
            id: id.value,
            name: name ?? id.value
        )
    }
}

nonisolated private struct ModInstalledProjectsPayload: Decodable {
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

nonisolated private struct ModInstalledProjectsIdentifiedPayload: Decodable {
    let identified: [ModInstalledProjectPayload]
}

nonisolated private struct ModInstalledProjectPayload: Decodable {
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

nonisolated private struct ModInstalledProjectUpdatePayload: Decodable {
    let id: ModLossyString
    let name: String
    
    var model: MinecraftProjectUpdate {
        MinecraftProjectUpdate(id: id.value, name: name)
    }
}

nonisolated private struct MinecraftModInstallPayload: Encodable, Sendable {
    let provider: String
    let modId: String
    let versionId: String
    
    private enum CodingKeys: String, CodingKey {
        case provider,
             modId = "mod_id",
             versionId = "version_id"
    }
}
