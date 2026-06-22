import Foundation
import Calagopus

@Observable
final class PluginInstallerVM {
    private let id: String
    private var serverId: String
    private var pluginSearchCache: [PluginSearchCacheKey: PluginCatalogSearchResult] = [:]
    
    init(_ id: String) {
        self.id = id
        serverId = id
    }
    
    private(set) var pluginManagerAvailable = true
    
    private(set) var isLoadingPlugins = false
    private(set) var isInstallingPlugin = false
    private(set) var plugins: [MinecraftCatalogProject] = []
    private(set) var pluginVersions: [MinecraftCatalogVersion] = []
    private(set) var installedPlugins: [MinecraftInstalledProject] = []
    private(set) var pluginsPagination = MinecraftPagination()
    private(set) var versionOptions: [String] = []
    private(set) var pluginLoaderOptions: [String] = []
    private(set) var isLoadingPolymart = false
    private(set) var isPolymartLinked = false
    
    func setServerId(_ id: String) {
        guard !id.isEmpty else { return }
        
        if serverId.caseInsensitiveCompare(id) != .orderedSame {
            clearPluginSearchCache()
        }
        
        serverId = id
    }
    
    func fetchMinecraftPlugins(
        provider: PluginProvider,
        page: Int = 1,
        pageSize: Int = 50,
        searchQuery: String = "",
        version: String = "",
        pluginLoader: String = "",
        forceRefresh: Bool = false
    ) async {
        guard pluginManagerAvailable else {
            return
        }
        
        let normalizedSearchQuery = trimmedSearchValue(searchQuery)
        let normalizedMinecraftVersion = trimmedSearchValue(version)
        let normalizedPluginLoader = trimmedSearchValue(pluginLoader)
        let cacheKey = PluginSearchCacheKey(
            provider: provider,
            page: page,
            pageSize: pageSize,
            version: normalizedMinecraftVersion,
            pluginLoader: normalizedPluginLoader
        )
        
        if normalizedSearchQuery.isEmpty,
           !forceRefresh,
           let cachedResponse = pluginSearchCache[cacheKey] {
            applySearchResult(cachedResponse)
            return
        }
        
        isLoadingPlugins = true
        defer {
            isLoadingPlugins = false
        }
        
        do {
            async let responseTask = loadMinecraftPlugins(
                provider: provider,
                page: page,
                pageSize: pageSize,
                searchQuery: normalizedSearchQuery,
                version: normalizedMinecraftVersion,
                pluginLoader: normalizedPluginLoader
            )
            async let manifestVersionsTask = fetchMinecraftVersionsFromManifest()
            
            let response = try await responseTask
            let enrichedResponse = await enrichedModrinthStats(response, provider: provider)
            applySearchResult(enrichedResponse, manifestVersions: await manifestVersionsTask)
            
            if normalizedSearchQuery.isEmpty {
                pluginSearchCache[cacheKey] = enrichedResponse
            }
        } catch {
            if isAddonMissing(error) {
                pluginManagerAvailable = false
                plugins = []
                pluginVersions = []
                installedPlugins = []
                versionOptions = []
                pluginLoaderOptions = []
                clearPluginSearchCache()
                return
            }
            
            SystemAlert.error(error)
        }
    }
    
    func fetchMinecraftPluginVersions(
        provider: PluginProvider,
        pluginId: String,
        pluginLoader: String = "",
        version: String = ""
    ) async {
        guard pluginManagerAvailable else {
            return
        }
        
        pluginVersions = []
        
        do {
            pluginVersions = try await loadMinecraftPluginVersions(
                provider: provider,
                pluginId: pluginId,
                pluginLoader: pluginLoader,
                version: version
            )
        } catch {
            if isAddonMissing(error) {
                pluginManagerAvailable = false
                pluginVersions = []
                return
            }
            
            SystemAlert.error(error)
        }
    }
    
    @discardableResult
    func installMinecraftPlugin(
        provider: PluginProvider,
        pluginId: String,
        versionId: String
    ) async -> Bool {
        guard pluginManagerAvailable else {
            return false
        }
        
        isInstallingPlugin = true
        defer {
            isInstallingPlugin = false
        }
        
        do {
            try await requestMinecraftPluginInstall(
                provider: provider,
                pluginId: pluginId,
                versionId: versionId
            )
            await fetchInstalledMinecraftPlugins()
            SystemAlert.done("Plugin installed")
            return true
        } catch {
            if isAddonMissing(error) {
                pluginManagerAvailable = false
                pluginVersions = []
                return false
            }
            
            SystemAlert.error(error)
            return false
        }
    }
    
    func fetchInstalledMinecraftPlugins() async {
        guard pluginManagerAvailable else {
            return
        }
        
        do {
            installedPlugins = try await loadInstalledMinecraftPlugins()
            pluginManagerAvailable = true
        } catch {
            if isAddonMissing(error) {
                pluginManagerAvailable = false
                installedPlugins = []
                return
            }
            
            SystemAlert.error(error)
        }
    }
    
    func fetchMinecraftPolymartLinkStatus() async {
        guard pluginManagerAvailable else {
            return
        }
        
        isLoadingPolymart = true
        defer {
            isLoadingPolymart = false
        }
        
        do {
            isPolymartLinked = try await loadMinecraftPolymartStatus()
            pluginManagerAvailable = true
        } catch {
            if isAddonMissing(error) {
                pluginManagerAvailable = false
                isPolymartLinked = false
                return
            }
            
            SystemAlert.error(error)
        }
    }
    
    func connectMinecraftPolymart() async -> URL? {
        guard pluginManagerAvailable else {
            return nil
        }
        
        isLoadingPolymart = true
        defer {
            isLoadingPolymart = false
        }
        
        do {
            let redirect = try await requestMinecraftPolymartConnect()
            isPolymartLinked = true
            return URL(string: redirect)
        } catch {
            if isAddonMissing(error) {
                pluginManagerAvailable = false
                isPolymartLinked = false
                return nil
            }
            
            SystemAlert.error(error)
            return nil
        }
    }
    
    func disconnectMinecraftPolymart() async {
        guard pluginManagerAvailable else {
            return
        }
        
        isLoadingPolymart = true
        defer {
            isLoadingPolymart = false
        }
        
        do {
            try await requestMinecraftPolymartDisconnect()
            isPolymartLinked = false
            pluginManagerAvailable = true
            SystemAlert.done("Polymart disconnected")
        } catch {
            if isAddonMissing(error) {
                pluginManagerAvailable = false
                isPolymartLinked = false
                return
            }
            
            SystemAlert.error(error)
        }
    }
    
    func clearPluginSearchCache() {
        pluginSearchCache = [:]
    }
}

private extension PluginInstallerVM {
    func applySearchResult(_ response: PluginCatalogSearchResult, manifestVersions: [String]? = nil) {
        plugins = response.projects
        pluginsPagination = response.pagination
        
        let resolvedManifestVersions: [String]
        if let manifestVersions {
            resolvedManifestVersions = manifestVersions
        } else {
            resolvedManifestVersions = []
        }
        
        versionOptions = resolvedManifestVersions.isEmpty
        ? normalizedOptions(response.versions)
        : resolvedManifestVersions
        pluginLoaderOptions = normalizedOptions(response.pluginLoaders)
        pluginManagerAvailable = true
        prefetchMinecraftIcons(response.projects)
    }
    
    func trimmedSearchValue(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func loadMinecraftPlugins(
        provider: PluginProvider,
        page: Int,
        pageSize: Int,
        searchQuery: String,
        version: String,
        pluginLoader: String
    ) async throws -> PluginCatalogSearchResult {
        let response: PluginProjectsListResponse = try await requestMinecraftPlugin(
            path: "minecraft/plugins",
            query: normalizedQueryItems([
                URLQueryItem(name: "provider", value: provider.rawValue),
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "page_size", value: String(pageSize)),
                URLQueryItem(name: "search_query", value: searchQuery),
                URLQueryItem(name: "minecraft_version", value: version),
                URLQueryItem(name: "plugin_loader", value: pluginLoader)
            ])
        )
        
        return PluginCatalogSearchResult(
            projects: response.data.map(\.model),
            pagination: response.meta.pagination.model,
            versions: response.meta.versions,
            pluginLoaders: response.meta.pluginLoaders
        )
    }
    
    func loadMinecraftPluginVersions(
        provider: PluginProvider,
        pluginId: String,
        pluginLoader: String,
        version: String
    ) async throws -> [MinecraftCatalogVersion] {
        let response: [PluginProjectVersionPayload] = try await requestMinecraftPlugin(
            path: "minecraft/plugins/versions",
            query: normalizedQueryItems([
                URLQueryItem(name: "provider", value: provider.rawValue),
                URLQueryItem(name: "plugin_id", value: pluginId),
                URLQueryItem(name: "plugin_loader", value: pluginLoader),
                URLQueryItem(name: "minecraft_version", value: version)
            ])
        )
        
        return response.map(\.model)
    }
    
    func requestMinecraftPluginInstall(
        provider: PluginProvider,
        pluginId: String,
        versionId: String
    ) async throws {
        let payload = PluginInstallPayload(
            provider: provider.rawValue,
            pluginId: pluginId,
            versionId: versionId
        )
        
        try await requestMinecraftPluginPost(
            path: "minecraft/plugins/install",
            body: payload,
            timeout: 60 * 60
        )
    }
    
    func loadInstalledMinecraftPlugins() async throws -> [MinecraftInstalledProject] {
        let response: PluginInstalledProjectsPayload = try await requestMinecraftPlugin(path: "minecraft/plugins/installed")
        
        return response.projects
    }
    
    func loadMinecraftPolymartStatus() async throws -> Bool {
        try await requestMinecraftPlugin(path: "minecraft/plugins/polymart/linked")
    }
    
    func requestMinecraftPolymartConnect() async throws -> String {
        let response: PluginPolymartLinkResponse = try await requestMinecraftPlugin(
            path: "minecraft/plugins/polymart/link",
            method: .post,
            body: EmptyPayload()
        )
        
        return response.redirectURL
    }
    
    func requestMinecraftPolymartDisconnect() async throws {
        try await requestMinecraftPluginPost(
            path: "minecraft/plugins/polymart/disconnect",
            body: EmptyPayload()
        )
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
    
    func requestMinecraftPlugin<Response: Decodable>(
        path: String,
        query: [URLQueryItem] = [],
        method: HTTPMethod = .get,
        body: (any Encodable & Sendable)? = nil,
        timeout: TimeInterval = 60
    ) async throws -> Response {
        try await requestMinecraftPlugin(
            path: path,
            query: query,
            method: method,
            body: body,
            timeout: timeout
        ) { data, _ in
            try BigAssDecoder.decode(Response.self, from: data)
        }
    }
    
    func requestMinecraftPluginPost(
        path: String,
        body: any Encodable & Sendable,
        timeout: TimeInterval = 60
    ) async throws {
        try await requestMinecraftPlugin(path: path, method: .post, body: body, timeout: timeout) { _, _ in () }
    }
    
    func requestMinecraftPlugin<Response>(
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
                try validateMinecraftPluginResponse(data: data, response: response)
                
                return try decode(data, response)
            } catch {
                let isLast = index == candidates.index(before: candidates.endIndex)
                
                if !isLast, isAddonMissing(error) {
                    continue
                }
                
                throw error
            }
        }
        
        throw MinecraftInstallerRequestError.emptyResponse
    }
    
    func validateMinecraftPluginResponse(data: Data, response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw MinecraftInstallerRequestError.emptyResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let error = try? BigAssDecoder.decode(PterError.self, from: data) {
                throw error
            }
            
            throw MinecraftInstallerRequestError.badStatusCode(httpResponse.statusCode)
        }
    }
    
    func serverCandidates() -> [String] {
        guard serverId.caseInsensitiveCompare(id) != .orderedSame else {
            return [serverId]
        }
        
        return [serverId, id]
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
        _ response: PluginCatalogSearchResult,
        provider: PluginProvider
    ) async -> PluginCatalogSearchResult {
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
                category: .bukkitPlugins
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
        case .hangar, .spigotmc, .polymart:
            return response
        }
        
        return PluginCatalogSearchResult(
            projects: projects,
            pagination: response.pagination,
            versions: response.versions,
            pluginLoaders: response.pluginLoaders
        )
    }
}

private struct PluginCatalogSearchResult {
    let projects: [MinecraftCatalogProject]
    let pagination: MinecraftPagination
    let versions: [String]
    let pluginLoaders: [String]
}

private struct PluginSearchCacheKey: Hashable {
    let provider: PluginProvider
    let page: Int
    let pageSize: Int
    let version: String
    let pluginLoader: String
}

nonisolated private struct PluginPolymartLinkResponse: Decodable {
    let redirectURL: String
}

nonisolated private struct PluginLossyString: Decodable {
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

nonisolated private struct PluginLossyInt: Decodable {
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

nonisolated private struct PluginProjectsListResponse: Decodable {
    let data: [PluginProjectPayload]
    let meta: PluginProjectsMetaPayload
    
    private enum CodingKeys: String, CodingKey {
        case data, meta
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let data = try container.decodeIfPresent([PluginProjectPayload].self, forKey: .data),
           let meta = try container.decodeIfPresent(PluginProjectsMetaPayload.self, forKey: .meta) {
            self.data = data
            self.meta = meta
            return
        }
        
        let page = try PluginPaginatedProjectsPayload(from: decoder)
        data = page.data
        meta = PluginProjectsMetaPayload(pagination: page.pagination, versions: [], pluginLoaders: [])
    }
}

nonisolated private struct PluginProjectsMetaPayload: Decodable {
    let pagination: PluginPaginationPayload
    let versions: [String]
    let pluginLoaders: [String]
    
    init(pagination: PluginPaginationPayload, versions: [String], pluginLoaders: [String]) {
        self.pagination = pagination
        self.versions = versions
        self.pluginLoaders = pluginLoaders
    }
    
    private enum CodingKeys: String, CodingKey {
        case pagination
        case versions
        case minecraftVersionsLegacy = "minecraftVersions"
        case minecraftVersionsSnake = "minecraft_versions"
        case pluginLoaders
        case pluginLoadersSnake = "plugin_loaders"
        case filters
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        pagination = try container.decode(PluginPaginationPayload.self, forKey: .pagination)
        
        let directMinecraftVersions = try container.decodeIfPresent([String].self, forKey: .versions)
        ?? container.decodeIfPresent([String].self, forKey: .minecraftVersionsLegacy)
        ?? container.decodeIfPresent([String].self, forKey: .minecraftVersionsSnake)
        ?? []
        
        let directPluginLoaders = try container.decodeIfPresent([String].self, forKey: .pluginLoaders)
        ?? container.decodeIfPresent([String].self, forKey: .pluginLoadersSnake)
        ?? []
        
        let filterPayload = try container.decodeIfPresent(PluginFilterOptionsPayload.self, forKey: .filters)
        
        versions = directMinecraftVersions.isEmpty ? (filterPayload?.versions ?? []) : directMinecraftVersions
        pluginLoaders = directPluginLoaders.isEmpty ? (filterPayload?.pluginLoaders ?? []) : directPluginLoaders
    }
}

nonisolated private struct PluginPaginatedProjectsPayload: Decodable {
    let total: Int
    let perPage: Int
    let page: Int
    let data: [PluginProjectPayload]
    
    var pagination: PluginPaginationPayload {
        PluginPaginationPayload(total: total, currentPage: page, totalPages: max(1, Int(ceil(Double(total) / Double(max(1, perPage))))))
    }
}

nonisolated private struct PluginFilterOptionsPayload: Decodable {
    let versions: [String]
    let pluginLoaders: [String]
    
    private enum CodingKeys: String, CodingKey {
        case versions
        case minecraftVersionsLegacy = "minecraftVersions"
        case minecraftVersionsSnake = "minecraft_versions"
        case pluginLoaders
        case pluginLoadersSnake = "plugin_loaders"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        versions = try container.decodeIfPresent([String].self, forKey: .versions)
        ?? container.decodeIfPresent([String].self, forKey: .minecraftVersionsLegacy)
        ?? container.decodeIfPresent([String].self, forKey: .minecraftVersionsSnake)
        ?? []
        
        pluginLoaders = try container.decodeIfPresent([String].self, forKey: .pluginLoaders)
        ?? container.decodeIfPresent([String].self, forKey: .pluginLoadersSnake)
        ?? []
    }
}

nonisolated private struct PluginPaginationPayload: Decodable {
    let total: Int
    let currentPage: Int
    let totalPages: Int
    
    init(total: Int, currentPage: Int, totalPages: Int) {
        self.total = total
        self.currentPage = currentPage
        self.totalPages = totalPages
    }
    
    var model: MinecraftPagination {
        MinecraftPagination(
            currentPage: currentPage,
            totalPages: totalPages,
            total: total
        )
    }
}

nonisolated private struct PluginProjectPayload: Decodable {
    let id: PluginLossyString
    let name: String
    let shortDescription: String?
    let description: String?
    let url: String?
    let iconUrl: String?
    let imageUrl: String?
    let externalUrl: String?
    let likes: PluginLossyInt?
    let downloads: PluginLossyInt?
    
    private enum CodingKeys: String, CodingKey {
        case id, name, shortDescription, description, url, iconUrl, imageUrl, externalUrl, likes, downloads, follows, followers
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(PluginLossyString.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        shortDescription = try container.decodeIfPresent(String.self, forKey: .shortDescription)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        url = try container.decodeIfPresent(String.self, forKey: .url)
        iconUrl = try container.decodeIfPresent(String.self, forKey: .iconUrl)
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        externalUrl = try container.decodeIfPresent(String.self, forKey: .externalUrl)
        
        likes = try container.decodeIfPresent(PluginLossyInt.self, forKey: .likes)
        ?? container.decodeIfPresent(PluginLossyInt.self, forKey: .follows)
        ?? container.decodeIfPresent(PluginLossyInt.self, forKey: .followers)
        
        downloads = try container.decodeIfPresent(PluginLossyInt.self, forKey: .downloads)
    }
    
    var model: MinecraftCatalogProject {
        MinecraftCatalogProject(
            id: id.value,
            name: name,
            description: shortDescription ?? description ?? "",
            url: url,
            iconURLString: iconUrl ?? imageUrl,
            externalURL: externalUrl,
            likes: likes?.value,
            downloads: downloads?.value
        )
    }
}

nonisolated private struct PluginProjectVersionPayload: Decodable {
    let id: PluginLossyString
    let name: String?
    
    var model: MinecraftCatalogVersion {
        MinecraftCatalogVersion(
            id: id.value,
            name: name ?? id.value
        )
    }
}

nonisolated private struct PluginInstalledProjectsPayload: Decodable {
    let projects: [MinecraftInstalledProject]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let projects = try? container.decode([PluginInstalledProjectPayload].self) {
            self.projects = projects.map(\.model)
            return
        }
        
        if let identified = try? container.decode(PluginInstalledProjectsIdentifiedPayload.self) {
            self.projects = identified.identified.map(\.model)
            return
        }
        
        projects = []
    }
}

nonisolated private struct PluginInstalledProjectsIdentifiedPayload: Decodable {
    let identified: [PluginInstalledProjectPayload]
}

nonisolated private struct PluginInstalledProjectPayload: Decodable {
    let path: String
    let provider: String?
    let projectId: String?
    let projectName: String?
    let versionId: String?
    let versionName: String?
    let iconUrl: String?
    let update: PluginInstalledProjectUpdatePayload?
    
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

nonisolated private struct PluginInstalledProjectUpdatePayload: Decodable {
    let id: PluginLossyString
    let name: String
    
    var model: MinecraftProjectUpdate {
        MinecraftProjectUpdate(id: id.value, name: name)
    }
}

nonisolated private struct PluginInstallPayload: Encodable, Sendable {
    let provider: String
    let pluginId: String
    let versionId: String
}

nonisolated private struct EmptyPayload: Encodable, Sendable {}
