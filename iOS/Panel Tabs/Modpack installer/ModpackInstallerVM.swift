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
    
    private(set) var minecraftModpackInstallerAvailable = true
    
    private(set) var isLoadingMinecraftModpacks = false
    private(set) var isInstallingMinecraftModpack = false
    private(set) var minecraftModpacks: [MinecraftCatalogProject] = []
    private(set) var minecraftModpackVersions: [MinecraftCatalogVersion] = []
    private(set) var minecraftModpacksPagination = MinecraftPagination()
    private(set) var installedMinecraftModpacks: [InstalledModpack] = []
    
    var mostRecentInstalledMinecraftModpack: InstalledModpack? {
        installedMinecraftModpacks.first
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
        guard minecraftModpackInstallerAvailable else { return }
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
        
        isLoadingMinecraftModpacks = true
        
        defer {
            isLoadingMinecraftModpacks = false
        }
        
        do {
            let response = try await fetchMinecraftModpacksAPI(
                provider: provider,
                page: page,
                pageSize: pageSize,
                searchQuery: normalizedSearchQuery
            )
            
            applySearchResult(response)
            
            if normalizedSearchQuery.isEmpty {
                modpackSearchCache[cacheKey] = response
            }
        } catch {
            if isAddonMissing(error) {
                minecraftModpackInstallerAvailable = false
                minecraftModpacks = []
                minecraftModpackVersions = []
                installedMinecraftModpacks = []
                clearModpackSearchCache()
                return
            }
            
            SystemAlert.error(error)
        }
    }
    
    func fetchMinecraftModpackVersions(provider: ModpackProvider, modpackId: String) async {
        guard minecraftModpackInstallerAvailable else {
            return
        }
        
        minecraftModpackVersions = []
        
        do {
            minecraftModpackVersions = try await fetchMinecraftModpackVersionsAPI(
                provider: provider,
                modpackId: modpackId
            )
        } catch {
            if isAddonMissing(error) {
                minecraftModpackInstallerAvailable = false
                minecraftModpackVersions = []
                return
            }
            
            SystemAlert.error(error)
        }
    }
    
    @discardableResult
    func installMinecraftModpack(
        provider: ModpackProvider,
        modpackId: String,
        versionId: String,
        deleteServerFiles: Bool
    ) async -> Bool {
        guard minecraftModpackInstallerAvailable else {
            return false
        }
        
        isInstallingMinecraftModpack = true
        defer {
            isInstallingMinecraftModpack = false
        }
        
        do {
            try await installMinecraftModpackAPI(
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
                minecraftModpackInstallerAvailable = false
                minecraftModpackVersions = []
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
        minecraftModpacks = response.projects
        minecraftModpacksPagination = response.pagination
        installedMinecraftModpacks = response.installedModpacks
        minecraftModpackInstallerAvailable = true
        prefetchMinecraftIcons(response.projects)
    }
    
    func trimmedSearchValue(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func fetchMinecraftModpacksAPI(
        provider: ModpackProvider,
        page: Int,
        pageSize: Int,
        searchQuery: String
    ) async throws -> ModpackSearchResult {
        
        var query = [
            URLQueryItem(name: "provider", value: provider.rawValue),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "page_size", value: String(pageSize))
        ]
        
        appendQueryItem(name: "search_query", value: searchQuery, query: &query)
        
        let response: ModpackListResponse = try await minecraftToolsServerRequest(
            endpoint: "minecraft-modpacks",
            query: query
        )
        
        return ModpackSearchResult(
            projects: response.data.map(\.model),
            pagination: response.meta.pagination.model,
            installedModpacks: response.meta.installedModpacks.map(\.model)
        )
    }
    
    func fetchMinecraftModpackVersionsAPI(provider: ModpackProvider, modpackId: String) async throws -> [MinecraftCatalogVersion] {
        let query = [
            URLQueryItem(name: "provider", value: provider.rawValue),
            URLQueryItem(name: "modpack_id", value: modpackId)
        ]
        
        let response: [ModpackProjectVersionPayload] = try await minecraftToolsServerRequest(
            endpoint: "minecraft-modpacks/versions",
            query: query
        )
        
        return response.map(\.model)
    }
    
    func installMinecraftModpackAPI(
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
        
        try await minecraftToolsServerPost(endpoint: "minecraft-modpacks/install", body: payload, timeout: 60 * 60)
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
    
    func performRequest<Response: Decodable>(path: String, method: HTTPMethod = .get, body: Encodable? = nil, timeout: TimeInterval = 60) async throws -> Response {
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
        guard !iconURLs.isEmpty else { return }
        
        Prefetcher.prefetchImages(iconURLs)
    }
}

private enum MinecraftToolsRequestError: Error {
    case noApiKey, badRequest, emptyResponse
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

private struct ModpackListResponse: Decodable {
    let data: [ModpackProjectPayload]
    let meta: ModpackMetaPayload
}

private struct ModpackMetaPayload: Decodable {
    let pagination: ModpackPaginationPayload
    let installedModpacks: [ModpackInstalledModpackPayload]
    
    private enum CodingKeys: String, CodingKey {
        case pagination
        case installedModpacks
        case installedModpack
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
    
    var model: MinecraftCatalogProject {
        MinecraftCatalogProject(
            id: id.value,
            name: name,
            description: shortDescription ?? description ?? "",
            url: url,
            iconURLString: iconUrl,
            externalURL: externalUrl
        )
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

private struct ModpackInstallPayload: Encodable {
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
