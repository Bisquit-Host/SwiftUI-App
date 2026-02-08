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

    private(set) var minecraftModManagerAvailable = true

    private(set) var isLoadingMinecraftMods = false
    private(set) var isInstallingMinecraftMod = false
    private(set) var minecraftMods: [MinecraftCatalogProject] = []
    private(set) var minecraftModVersions: [MinecraftCatalogVersion] = []
    private(set) var installedMinecraftMods: [MinecraftInstalledProject] = []
    private(set) var minecraftModsPagination = MinecraftPagination()
    private(set) var minecraftVersionOptions: [String] = []
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
        minecraftVersion: String = "",
        modLoader: String = "",
        forceRefresh: Bool = false
    ) async {
        guard minecraftModManagerAvailable else {
            return
        }

        let normalizedSearchQuery = trimmedSearchValue(searchQuery)
        let normalizedMinecraftVersion = trimmedSearchValue(minecraftVersion)
        let normalizedModLoader = trimmedSearchValue(modLoader)
        let cacheKey = ModSearchCacheKey(
            provider: provider,
            page: page,
            pageSize: pageSize,
            minecraftVersion: normalizedMinecraftVersion,
            modLoader: normalizedModLoader
        )

        if normalizedSearchQuery.isEmpty,
           !forceRefresh,
           let cachedResponse = modSearchCache[cacheKey] {
            applySearchResult(cachedResponse)
            return
        }

        isLoadingMinecraftMods = true
        defer {
            isLoadingMinecraftMods = false
        }

        do {
            async let responseTask = fetchMinecraftModsAPI(
                provider: provider,
                page: page,
                pageSize: pageSize,
                searchQuery: normalizedSearchQuery,
                minecraftVersion: normalizedMinecraftVersion,
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
                minecraftModManagerAvailable = false
                minecraftMods = []
                minecraftModVersions = []
                installedMinecraftMods = []
                minecraftVersionOptions = []
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
        minecraftVersion: String = ""
    ) async {
        guard minecraftModManagerAvailable else {
            return
        }

        minecraftModVersions = []

        do {
            minecraftModVersions = try await fetchMinecraftModVersionsAPI(
                provider: provider,
                modId: modId,
                modLoader: modLoader,
                minecraftVersion: minecraftVersion
            )
        } catch {
            if isAddonMissing(error) {
                minecraftModManagerAvailable = false
                minecraftModVersions = []
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
        guard minecraftModManagerAvailable else {
            return false
        }

        isInstallingMinecraftMod = true
        defer {
            isInstallingMinecraftMod = false
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
                minecraftModManagerAvailable = false
                minecraftModVersions = []
                return false
            }

            SystemAlert.error(error)
            return false
        }
    }

    func fetchInstalledMinecraftMods() async {
        guard minecraftModManagerAvailable else {
            return
        }

        do {
            installedMinecraftMods = try await fetchInstalledMinecraftModsAPI()
            minecraftModManagerAvailable = true
        } catch {
            if isAddonMissing(error) {
                minecraftModManagerAvailable = false
                installedMinecraftMods = []
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
        minecraftMods = response.projects
        minecraftModsPagination = response.pagination

        let resolvedManifestVersions: [String]
        if let manifestVersions {
            resolvedManifestVersions = manifestVersions
        } else {
            resolvedManifestVersions = []
        }

        minecraftVersionOptions = resolvedManifestVersions.isEmpty
            ? normalizedOptions(response.minecraftVersions)
            : resolvedManifestVersions
        modLoaderOptions = normalizedOptions(response.modLoaders)
        minecraftModManagerAvailable = true
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
        minecraftVersion: String,
        modLoader: String
    ) async throws -> ModCatalogSearchResult {
        var query = [
            URLQueryItem(name: "provider", value: provider.rawValue),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "page_size", value: String(pageSize))
        ]

        appendQueryItem(name: "search_query", value: searchQuery, query: &query)
        appendQueryItem(name: "minecraft_version", value: minecraftVersion, query: &query)
        appendQueryItem(name: "mod_loader", value: modLoader, query: &query)

        let response: ModProjectsListResponse = try await minecraftToolsServerRequest(
            endpoint: "minecraft-mods",
            query: query
        )

        return ModCatalogSearchResult(
            projects: response.data.map(\.model),
            pagination: response.meta.pagination.model,
            minecraftVersions: response.meta.minecraftVersions,
            modLoaders: response.meta.modLoaders
        )
    }

    func fetchMinecraftModVersionsAPI(
        provider: ModManagerProvider,
        modId: String,
        modLoader: String,
        minecraftVersion: String
    ) async throws -> [MinecraftCatalogVersion] {
        var query = [
            URLQueryItem(name: "provider", value: provider.rawValue),
            URLQueryItem(name: "modId", value: modId)
        ]

        appendQueryItem(name: "modLoader", value: modLoader, query: &query)
        appendQueryItem(name: "minecraftVersion", value: minecraftVersion, query: &query)

        let response: [ModProjectVersionPayload] = try await minecraftToolsServerRequest(
            endpoint: "minecraft-mods/versions",
            query: query
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

        try await minecraftToolsServerPost(endpoint: "minecraft-mods/install", body: payload, timeout: 60 * 60)
    }

    func fetchInstalledMinecraftModsAPI() async throws -> [MinecraftInstalledProject] {
        let response: ModInstalledProjectsPayload = try await minecraftToolsServerRequest(
            endpoint: "minecraft-mods/installed"
        )

        return response.projects
    }

    func minecraftToolsServerRequest<Response: Decodable>(
        endpoint: String,
        query: [URLQueryItem] = [],
        method: HTTPMethod = .get,
        body: Encodable? = nil,
        timeout: TimeInterval = 60
    ) async throws -> Response {
        let queryPart = buildQuerySuffix(query)
        let candidates = serverCandidates

        for (index, candidateServerId) in candidates.enumerated() {
            do {
                return try await performRequest(
                    path: "client/servers/\(candidateServerId)/\(endpoint)\(queryPart)",
                    method: method,
                    body: body,
                    timeout: timeout
                )
            } catch {
                let isLast = index == candidates.index(before: candidates.endIndex)

                if isAddonMissing(error), isLast == false {
                    continue
                }

                throw error
            }
        }

        throw MinecraftToolsRequestError.emptyResponse
    }

    func minecraftToolsServerPost(endpoint: String, body: Encodable, timeout: TimeInterval) async throws {
        let candidates = serverCandidates

        for (index, candidateServerId) in candidates.enumerated() {
            do {
                var request = try createRequest(
                    path: "client/servers/\(candidateServerId)/\(endpoint)",
                    method: .post,
                    body: body
                )

                request.timeoutInterval = timeout

                let (data, response) = try await URLSession.shared.data(for: request)

                switch processPostResponse(data, response, nil) {
                case .success:
                    return

                case .failure(let error):
                    throw error
                }
            } catch {
                let isLast = index == candidates.index(before: candidates.endIndex)

                if isAddonMissing(error), isLast == false {
                    continue
                }

                throw error
            }
        }
    }

    var serverCandidates: [String] {
        if serverId.caseInsensitiveCompare(id) == .orderedSame {
            return [serverId]
        }

        return [serverId, id]
    }

    func appendQueryItem(name: String, value: String, query: inout [URLQueryItem]) {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            return
        }

        query.append(URLQueryItem(name: name, value: trimmed))
    }

    func buildQuerySuffix(_ query: [URLQueryItem]) -> String {
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

    func performRequest<Response: Decodable>(
        path: String,
        method: HTTPMethod = .get,
        body: Encodable? = nil,
        timeout: TimeInterval = 60
    ) async throws -> Response {
        var request = try createRequest(path: path, method: method, body: body)
        request.timeoutInterval = timeout

        let (data, response) = try await URLSession.shared.data(for: request)

        let result: Result<Response?, Error> = processResponse(data, response, nil)

        switch result {
        case .success(let model):
            guard let model else {
                throw MinecraftToolsRequestError.emptyResponse
            }

            return model

        case .failure(let error):
            throw error
        }
    }

    func createRequest(path: String, method: HTTPMethod = .get, body: Encodable? = nil) throws -> URLRequest {
        guard let apiKey = Keychain.load(key: "selectedApiKey") else {
            throw MinecraftToolsRequestError.noApiKey
        }

        guard let request = URLRequest(httpMethod: method, path: path, body: body, apiKey: apiKey) else {
            throw MinecraftToolsRequestError.badRequest
        }

        return request
    }

    func isAddonMissing(_ error: Error) -> Bool {
        guard let error = error as? PterError else {
            return false
        }

        return error.status == "404"
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
            return try await ModMinecraftVersionManifestLoader.shared.fetchReleaseVersions()
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

                return project.replacingStats(likes: stats.likes, downloads: stats.downloads)
            }
        case .curseforge:
            let statsByProject = await CurseForgeProjectStatsService.shared.fetchStats(
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
            minecraftVersions: response.minecraftVersions,
            modLoaders: response.modLoaders
        )
    }
}

private enum MinecraftToolsRequestError: Error {
    case noApiKey, badRequest, emptyResponse
}

private struct ModCatalogSearchResult {
    let projects: [MinecraftCatalogProject]
    let pagination: MinecraftPagination
    let minecraftVersions: [String]
    let modLoaders: [String]
}

private struct ModSearchCacheKey: Hashable {
    let provider: ModManagerProvider
    let page: Int
    let pageSize: Int
    let minecraftVersion: String
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
    let minecraftVersions: [String]
    let modLoaders: [String]
    
    private enum CodingKeys: String, CodingKey {
        case pagination
        case minecraftVersions
        case minecraftVersionsSnake = "minecraft_versions"
        case modLoaders
        case modLoadersSnake = "mod_loaders"
        case filters
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        pagination = try container.decode(ModPaginationPayload.self, forKey: .pagination)
        
        let directMinecraftVersions = try container.decodeIfPresent([String].self, forKey: .minecraftVersions)
            ?? container.decodeIfPresent([String].self, forKey: .minecraftVersionsSnake)
            ?? []
        
        let directModLoaders = try container.decodeIfPresent([String].self, forKey: .modLoaders)
            ?? container.decodeIfPresent([String].self, forKey: .modLoadersSnake)
            ?? []
        
        let filterPayload = try container.decodeIfPresent(ModFilterOptionsPayload.self, forKey: .filters)
        
        minecraftVersions = directMinecraftVersions.isEmpty ? (filterPayload?.minecraftVersions ?? []) : directMinecraftVersions
        modLoaders = directModLoaders.isEmpty ? (filterPayload?.modLoaders ?? []) : directModLoaders
    }
}

private struct ModFilterOptionsPayload: Decodable {
    let minecraftVersions: [String]
    let modLoaders: [String]
    
    private enum CodingKeys: String, CodingKey {
        case minecraftVersions
        case minecraftVersionsSnake = "minecraft_versions"
        case modLoaders
        case modLoadersSnake = "mod_loaders"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        minecraftVersions = try container.decodeIfPresent([String].self, forKey: .minecraftVersions)
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

private actor ModMinecraftVersionManifestLoader {
    static let shared = ModMinecraftVersionManifestLoader()

    private let manifestURL = URL(string: "https://piston-meta.mojang.com/mc/game/version_manifest_v2.json")
    private let cacheTTL: TimeInterval = 60 * 60
    private var cachedReleaseVersions: [String] = []
    private var lastFetchAt: Date?

    func fetchReleaseVersions() async throws -> [String] {
        if let lastFetchAt,
           Date().timeIntervalSince(lastFetchAt) < cacheTTL,
           cachedReleaseVersions.isEmpty == false {
            return cachedReleaseVersions
        }

        guard let manifestURL else {
            throw MinecraftManifestError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: manifestURL)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw MinecraftManifestError.badResponse
        }

        let payload = try JSONDecoder().decode(MinecraftManifestPayload.self, from: data)
        let releases = normalizedOptions(payload.versions.filter { $0.type == "release" }.map(\.id))

        guard releases.isEmpty == false else {
            throw MinecraftManifestError.emptyVersions
        }

        cachedReleaseVersions = releases
        lastFetchAt = Date()
        return releases
    }

    func normalizedOptions(_ values: [String]) -> [String] {
        var output: [String] = []
        var seen = Set<String>()

        for value in values {
            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmed.isEmpty == false, seen.insert(trimmed).inserted else {
                continue
            }

            output.append(trimmed)
        }

        return output
    }
}

private enum MinecraftManifestError: Error {
    case invalidURL, badResponse, emptyVersions
}

nonisolated private struct MinecraftManifestPayload: Decodable {
    let versions: [MinecraftManifestVersionPayload]
}

private struct MinecraftManifestVersionPayload: Decodable {
    let id: String
    let type: String
}
