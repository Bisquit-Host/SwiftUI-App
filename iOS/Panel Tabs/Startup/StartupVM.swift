import Foundation
import PteroNet

@Observable
final class StartupVM {
    private let id: String
    private var versionChangerServerId: String
    private var minecraftToolsServerId: String
    
    init(_ id: String) {
        self.id = id
        versionChangerServerId = id
        minecraftToolsServerId = id
    }
    
    private(set) var startupCommand = ""
    private(set) var rawStartupCommand = ""
    private(set) var startupVariables: [StartupVariable] = []
    private(set) var dockerImages: [String: String] = [:]
    
    private(set) var isLoadingVersionChanger = false
    private(set) var isInstallingVersionChanger = false
    private(set) var versionChangerAvailable = true
    private(set) var versionChangerTypes: [VersionChangerProviderType] = []
    private(set) var versionChangerVersions: [VersionChangerVersion] = []
    private(set) var versionChangerBuilds: [VersionChangerBuild] = []
    private(set) var versionChangerInstalled: VersionChangerInstalled?
    
    private(set) var minecraftModManagerAvailable = true
    private(set) var minecraftPluginManagerAvailable = true
    private(set) var minecraftModpackInstallerAvailable = true
    
    private(set) var isLoadingMinecraftMods = false
    private(set) var isInstallingMinecraftMod = false
    private(set) var minecraftMods: [MinecraftCatalogProject] = []
    private(set) var minecraftModVersions: [MinecraftCatalogVersion] = []
    private(set) var installedMinecraftMods: [MinecraftInstalledProject] = []
    private(set) var minecraftModsPagination = MinecraftPagination()
    
    private(set) var isLoadingMinecraftPlugins = false
    private(set) var isInstallingMinecraftPlugin = false
    private(set) var minecraftPlugins: [MinecraftCatalogProject] = []
    private(set) var minecraftPluginVersions: [MinecraftCatalogVersion] = []
    private(set) var installedMinecraftPlugins: [MinecraftInstalledProject] = []
    private(set) var minecraftPluginsPagination = MinecraftPagination()
    private(set) var isLoadingMinecraftPolymart = false
    private(set) var isMinecraftPolymartLinked = false
    
    private(set) var isLoadingMinecraftModpacks = false
    private(set) var isInstallingMinecraftModpack = false
    private(set) var minecraftModpacks: [MinecraftCatalogProject] = []
    private(set) var minecraftModpackVersions: [MinecraftCatalogVersion] = []
    private(set) var minecraftModpacksPagination = MinecraftPagination()
    private(set) var installedMinecraftModpack: MinecraftInstalledModpack?
    
    var sortedDockerImages: [(key: String, value: String)] {
        Array(dockerImages)
            .sorted {
                guard
                    let firstKeyNumber = $0.key.split(separator: " ").last.flatMap({ Double($0) }),
                    let secondKeyNumber = $1.key.split(separator: " ").last.flatMap({ Double($0) })
                else {
                    return false
                }
                
                return firstKeyNumber > secondKeyNumber
            }
    }
    
    var installedVersionChangerType: VersionChangerProviderType? {
        guard let installedType = versionChangerInstalled?.build?.type else {
            return nil
        }
        
        if let exactMatch = versionChangerTypes.first(where: {
            $0.identifier.caseInsensitiveCompare(installedType) == .orderedSame
        }) {
            return exactMatch
        }
        
        let normalizedInstalledType = normalizeVersionChangerType(installedType)
        
        return versionChangerTypes.first { provider in
            let normalizedIdentifier = normalizeVersionChangerType(provider.identifier)
            let normalizedName = normalizeVersionChangerType(provider.name)
            
            return normalizedIdentifier == normalizedInstalledType
                || normalizedName == normalizedInstalledType
                || normalizedInstalledType.contains(normalizedIdentifier)
                || normalizedIdentifier.contains(normalizedInstalledType)
                || normalizedInstalledType.contains(normalizedName)
                || normalizedName.contains(normalizedInstalledType)
        }
    }
    
    func setVersionChangerServerId(_ id: String) {
        guard !id.isEmpty else {
            return
        }
        
        versionChangerServerId = id
    }
    
    func setMinecraftToolsServerId(_ id: String) {
        guard !id.isEmpty else {
            return
        }
        
        minecraftToolsServerId = id
    }
    
    func fetchStartupVariables() async {
        do {
            let model = try await startupListAPI(id)
            let meta = model.meta
            
            self.startupVariables = model.data.map(\.attributes)
            self.startupCommand = meta.startupCommand
            self.rawStartupCommand = meta.rawStartupCommand
            
            if let dockerImages = meta.dockerImages {
                self.dockerImages = dockerImages
            }
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func updateVariable(
        key: String,
        value: String,
        onSuccess: @escaping (StartupVariable) -> () = { _ in },
        onFailure: @escaping () -> ()
    ) async {
        do {
            let model = try await startupUpdateAPI(id, key: key, value: value)
            
            if let index = self.startupVariables.firstIndex(where: {
                $0.envVariable == model.attributes.envVariable
            }) {
                self.startupVariables[index] = model.attributes
            }
            
            onSuccess(model.attributes)
        } catch {
            SystemAlert.error(error)
            onFailure()
        }
    }
    
    func updateDockerImage(_ newImage: String) async {
        do {
            try await dockerUpdateAPI(id, newImage: newImage)
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func fetchVersionChangerData() async {
        isLoadingVersionChanger = true
        defer {
            isLoadingVersionChanger = false
        }
        
        do {
            async let types = fetchVersionChangerTypesAPI()
            async let installed = fetchInstalledVersionChangerAPI()
            
            let loadedTypes = try await types
            
            self.versionChangerTypes = loadedTypes
            self.versionChangerInstalled = try await installed
            prefetchVersionChangerTypeIcons(loadedTypes)
            versionChangerAvailable = true
        } catch {
            if isVersionChangerMissing(error) {
                versionChangerAvailable = false
                versionChangerTypes = []
                versionChangerVersions = []
                versionChangerBuilds = []
                versionChangerInstalled = nil
                return
            }
            
            SystemAlert.error(error)
        }
    }
    
    func fetchVersionChangerVersions(type: String) async {
        guard versionChangerAvailable else {
            return
        }
        
        do {
            versionChangerVersions = try await fetchVersionChangerVersionsAPI(type: type)
        } catch {
            if isVersionChangerMissing(error) {
                versionChangerAvailable = false
                clearVersionChangerSelection()
                return
            }
            
            SystemAlert.error(error)
        }
    }
    
    func fetchVersionChangerBuilds(type: String, version: String) async {
        guard versionChangerAvailable else {
            return
        }
        
        do {
            versionChangerBuilds = try await fetchVersionChangerBuildsAPI(type: type, version: version)
        } catch {
            if isVersionChangerMissing(error) {
                versionChangerAvailable = false
                clearVersionChangerSelection()
                return
            }
            
            SystemAlert.error(error)
        }
    }
    
    func clearVersionChangerSelection() {
        versionChangerVersions = []
        versionChangerBuilds = []
    }
    
    func clearVersionChangerBuildSelection() {
        versionChangerBuilds = []
    }
    
    @discardableResult
    func installVersionChangerBuild(_ build: Int, deleteFiles: Bool, acceptEula: Bool) async -> Bool {
        guard versionChangerAvailable else {
            return false
        }
        
        isInstallingVersionChanger = true
        defer {
            isInstallingVersionChanger = false
        }
        
        do {
            try await installVersionChangerAPI(build: build, deleteFiles: deleteFiles, acceptEula: acceptEula)
            await fetchInstalledVersionChanger()
            await fetchStartupVariables()
            SystemAlert.done("Version changed")
            return true
        } catch {
            if isVersionChangerMissing(error) {
                versionChangerAvailable = false
                clearVersionChangerSelection()
                return false
            }
            
            SystemAlert.error(error)
            return false
        }
    }
    
    func fetchInstalledVersionChanger() async {
        guard versionChangerAvailable else {
            return
        }
        
        do {
            versionChangerInstalled = try await fetchInstalledVersionChangerAPI()
        } catch {
            if isVersionChangerMissing(error) {
                versionChangerAvailable = false
                versionChangerInstalled = nil
                return
            }
            
            SystemAlert.error(error)
        }
    }
    
    func fetchMinecraftMods(
        provider: MinecraftModProvider,
        page: Int = 1,
        pageSize: Int = 25,
        searchQuery: String = "",
        minecraftVersion: String = "",
        modLoader: String = ""
    ) async {
        guard minecraftModManagerAvailable else {
            return
        }
        
        isLoadingMinecraftMods = true
        defer {
            isLoadingMinecraftMods = false
        }
        
        do {
            let response = try await fetchMinecraftModsAPI(
                provider: provider,
                page: page,
                pageSize: pageSize,
                searchQuery: searchQuery,
                minecraftVersion: minecraftVersion,
                modLoader: modLoader
            )
            
            minecraftMods = response.projects
            minecraftModsPagination = response.pagination
            minecraftModManagerAvailable = true
            prefetchMinecraftIcons(response.projects)
        } catch {
            if isVersionChangerMissing(error) {
                minecraftModManagerAvailable = false
                minecraftMods = []
                minecraftModVersions = []
                installedMinecraftMods = []
                return
            }
            
            SystemAlert.error(error)
        }
    }
    
    func fetchMinecraftModVersions(
        provider: MinecraftModProvider,
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
            if isVersionChangerMissing(error) {
                minecraftModManagerAvailable = false
                minecraftModVersions = []
                return
            }
            
            SystemAlert.error(error)
        }
    }
    
    @discardableResult
    func installMinecraftMod(
        provider: MinecraftModProvider,
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
            if isVersionChangerMissing(error) {
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
            if isVersionChangerMissing(error) {
                minecraftModManagerAvailable = false
                installedMinecraftMods = []
                return
            }
            
            SystemAlert.error(error)
        }
    }
    
    func fetchMinecraftPlugins(
        provider: MinecraftPluginProvider,
        page: Int = 1,
        pageSize: Int = 25,
        searchQuery: String = "",
        minecraftVersion: String = "",
        pluginLoader: String = ""
    ) async {
        guard minecraftPluginManagerAvailable else {
            return
        }
        
        isLoadingMinecraftPlugins = true
        defer {
            isLoadingMinecraftPlugins = false
        }
        
        do {
            let response = try await fetchMinecraftPluginsAPI(
                provider: provider,
                page: page,
                pageSize: pageSize,
                searchQuery: searchQuery,
                minecraftVersion: minecraftVersion,
                pluginLoader: pluginLoader
            )
            
            minecraftPlugins = response.projects
            minecraftPluginsPagination = response.pagination
            minecraftPluginManagerAvailable = true
            prefetchMinecraftIcons(response.projects)
        } catch {
            if isVersionChangerMissing(error) {
                minecraftPluginManagerAvailable = false
                minecraftPlugins = []
                minecraftPluginVersions = []
                installedMinecraftPlugins = []
                return
            }
            
            SystemAlert.error(error)
        }
    }
    
    func fetchMinecraftPluginVersions(
        provider: MinecraftPluginProvider,
        pluginId: String,
        pluginLoader: String = "",
        minecraftVersion: String = ""
    ) async {
        guard minecraftPluginManagerAvailable else {
            return
        }
        
        minecraftPluginVersions = []
        
        do {
            minecraftPluginVersions = try await fetchMinecraftPluginVersionsAPI(
                provider: provider,
                pluginId: pluginId,
                pluginLoader: pluginLoader,
                minecraftVersion: minecraftVersion
            )
        } catch {
            if isVersionChangerMissing(error) {
                minecraftPluginManagerAvailable = false
                minecraftPluginVersions = []
                return
            }
            
            SystemAlert.error(error)
        }
    }
    
    @discardableResult
    func installMinecraftPlugin(
        provider: MinecraftPluginProvider,
        pluginId: String,
        versionId: String
    ) async -> Bool {
        guard minecraftPluginManagerAvailable else {
            return false
        }
        
        isInstallingMinecraftPlugin = true
        defer {
            isInstallingMinecraftPlugin = false
        }
        
        do {
            try await installMinecraftPluginAPI(
                provider: provider,
                pluginId: pluginId,
                versionId: versionId
            )
            await fetchInstalledMinecraftPlugins()
            SystemAlert.done("Plugin installed")
            return true
        } catch {
            if isVersionChangerMissing(error) {
                minecraftPluginManagerAvailable = false
                minecraftPluginVersions = []
                return false
            }
            
            SystemAlert.error(error)
            return false
        }
    }
    
    func fetchInstalledMinecraftPlugins() async {
        guard minecraftPluginManagerAvailable else {
            return
        }
        
        do {
            installedMinecraftPlugins = try await fetchInstalledMinecraftPluginsAPI()
            minecraftPluginManagerAvailable = true
        } catch {
            if isVersionChangerMissing(error) {
                minecraftPluginManagerAvailable = false
                installedMinecraftPlugins = []
                return
            }
            
            SystemAlert.error(error)
        }
    }
    
    func fetchMinecraftPolymartLinkStatus() async {
        guard minecraftPluginManagerAvailable else {
            return
        }
        
        isLoadingMinecraftPolymart = true
        defer {
            isLoadingMinecraftPolymart = false
        }
        
        do {
            isMinecraftPolymartLinked = try await fetchMinecraftPolymartStatusAPI()
            minecraftPluginManagerAvailable = true
        } catch {
            if isVersionChangerMissing(error) {
                minecraftPluginManagerAvailable = false
                isMinecraftPolymartLinked = false
                return
            }
            
            SystemAlert.error(error)
        }
    }
    
    func connectMinecraftPolymart() async -> URL? {
        guard minecraftPluginManagerAvailable else {
            return nil
        }
        
        isLoadingMinecraftPolymart = true
        defer {
            isLoadingMinecraftPolymart = false
        }
        
        do {
            let redirect = try await connectMinecraftPolymartAPI()
            isMinecraftPolymartLinked = true
            return URL(string: redirect)
        } catch {
            if isVersionChangerMissing(error) {
                minecraftPluginManagerAvailable = false
                isMinecraftPolymartLinked = false
                return nil
            }
            
            SystemAlert.error(error)
            return nil
        }
    }
    
    func disconnectMinecraftPolymart() async {
        guard minecraftPluginManagerAvailable else {
            return
        }
        
        isLoadingMinecraftPolymart = true
        defer {
            isLoadingMinecraftPolymart = false
        }
        
        do {
            try await disconnectMinecraftPolymartAPI()
            isMinecraftPolymartLinked = false
            minecraftPluginManagerAvailable = true
            SystemAlert.done("Polymart disconnected")
        } catch {
            if isVersionChangerMissing(error) {
                minecraftPluginManagerAvailable = false
                isMinecraftPolymartLinked = false
                return
            }
            
            SystemAlert.error(error)
        }
    }
    
    func fetchMinecraftModpacks(
        provider: MinecraftModpackProvider,
        page: Int = 1,
        pageSize: Int = 25,
        searchQuery: String = ""
    ) async {
        guard minecraftModpackInstallerAvailable else {
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
                searchQuery: searchQuery
            )
            
            minecraftModpacks = response.projects
            minecraftModpacksPagination = response.pagination
            installedMinecraftModpack = response.installedModpack
            minecraftModpackInstallerAvailable = true
            prefetchMinecraftIcons(response.projects)
        } catch {
            if isVersionChangerMissing(error) {
                minecraftModpackInstallerAvailable = false
                minecraftModpacks = []
                minecraftModpackVersions = []
                installedMinecraftModpack = nil
                return
            }
            
            SystemAlert.error(error)
        }
    }
    
    func fetchMinecraftModpackVersions(
        provider: MinecraftModpackProvider,
        modpackId: String
    ) async {
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
            if isVersionChangerMissing(error) {
                minecraftModpackInstallerAvailable = false
                minecraftModpackVersions = []
                return
            }
            
            SystemAlert.error(error)
        }
    }
    
    @discardableResult
    func installMinecraftModpack(
        provider: MinecraftModpackProvider,
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
            SystemAlert.done("Modpack install started")
            return true
        } catch {
            if isVersionChangerMissing(error) {
                minecraftModpackInstallerAvailable = false
                minecraftModpackVersions = []
                return false
            }
            
            SystemAlert.error(error)
            return false
        }
    }
}

private extension StartupVM {
    func fetchVersionChangerTypesAPI() async throws -> [VersionChangerProviderType] {
        let response: VersionChangerTypesResponse = try await versionChangerServerRequest(endpoint: "types")
        
        var output = [VersionChangerProviderType]()
        
        for (category, types) in response.types {
            for (identifier, details) in types {
                output.append(
                    VersionChangerProviderType(
                        category: category,
                        identifier: identifier.uppercased(),
                        name: details.name,
                        icon: details.icon,
                        homepage: details.homepage,
                        description: details.description,
                        experimental: details.experimental,
                        deprecated: details.deprecated,
                        builds: details.builds,
                        versions: details.versions
                    )
                )
            }
        }
        
        return output.sorted { left, right in
            if left.category == right.category {
                return left.name.localizedStandardCompare(right.name) == .orderedAscending
            }
            
            return left.category.localizedStandardCompare(right.category) == .orderedAscending
        }
    }
    
    func fetchInstalledVersionChangerAPI() async throws -> VersionChangerInstalled? {
        let response: VersionChangerInstalledResponse = try await versionChangerServerRequest(endpoint: "installed")
        
        guard response.build != nil else {
            return nil
        }
        
        return VersionChangerInstalled(build: response.build, latest: response.latest)
    }
    
    func fetchVersionChangerVersionsAPI(type: String) async throws -> [VersionChangerVersion] {
        let response: VersionChangerVersionsResponse = try await versionChangerServerRequest(
            endpoint: "types/\(type.uppercased())"
        )
        
        return response.builds
            .map { version, details in
                VersionChangerVersion(
                    version: version,
                    type: details.type,
                    builds: details.builds,
                    latest: details.latest
                )
            }
            .sorted {
                $0.version.localizedStandardCompare($1.version) == .orderedDescending
            }
    }
    
    func fetchVersionChangerBuildsAPI(type: String, version: String) async throws -> [VersionChangerBuild] {
        var allowedCharacters = CharacterSet.urlPathAllowed
        allowedCharacters.remove(charactersIn: "/")
        
        let encodedVersion = version.addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? version
        
        let response: VersionChangerBuildsResponse = try await versionChangerServerRequest(
            endpoint: "types/\(type.uppercased())/\(encodedVersion)"
        )
        
        return response.builds.sorted { left, right in
            if left.experimental != right.experimental {
                return left.experimental == false
            }
            
            return left.name.localizedStandardCompare(right.name) == .orderedDescending
        }
    }
    
    func installVersionChangerAPI(build: Int, deleteFiles: Bool, acceptEula: Bool) async throws {
        let payload = VersionChangerInstallPayload(
            build: build,
            deleteFiles: deleteFiles,
            acceptEula: acceptEula
        )
        
        try await versionChangerServerPost(endpoint: "install", body: payload, timeout: 60 * 60)
    }
    
    func fetchMinecraftModsAPI(
        provider: MinecraftModProvider,
        page: Int,
        pageSize: Int,
        searchQuery: String,
        minecraftVersion: String,
        modLoader: String
    ) async throws -> MinecraftCatalogSearchResult {
        var query = [
            URLQueryItem(name: "provider", value: provider.rawValue),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "page_size", value: String(pageSize))
        ]
        
        appendQueryItem(name: "search_query", value: searchQuery, query: &query)
        appendQueryItem(name: "minecraft_version", value: minecraftVersion, query: &query)
        appendQueryItem(name: "mod_loader", value: modLoader, query: &query)
        
        let response: MinecraftProjectsListResponse = try await minecraftToolsServerRequest(
            endpoint: "minecraft-mods",
            query: query
        )
        
        return MinecraftCatalogSearchResult(
            projects: response.data.map(\.model),
            pagination: response.meta.pagination.model
        )
    }
    
    func fetchMinecraftModVersionsAPI(
        provider: MinecraftModProvider,
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
        
        let response: [MinecraftProjectVersionPayload] = try await minecraftToolsServerRequest(
            endpoint: "minecraft-mods/versions",
            query: query
        )
        
        return response.map(\.model)
    }
    
    func installMinecraftModAPI(
        provider: MinecraftModProvider,
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
        let response: MinecraftInstalledProjectsPayload = try await minecraftToolsServerRequest(
            endpoint: "minecraft-mods/installed"
        )
        
        return response.projects
    }
    
    func fetchMinecraftPluginsAPI(
        provider: MinecraftPluginProvider,
        page: Int,
        pageSize: Int,
        searchQuery: String,
        minecraftVersion: String,
        pluginLoader: String
    ) async throws -> MinecraftCatalogSearchResult {
        var query = [
            URLQueryItem(name: "provider", value: provider.rawValue),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "page_size", value: String(pageSize))
        ]
        
        appendQueryItem(name: "search_query", value: searchQuery, query: &query)
        appendQueryItem(name: "minecraft_version", value: minecraftVersion, query: &query)
        appendQueryItem(name: "plugin_loader", value: pluginLoader, query: &query)
        
        let response: MinecraftProjectsListResponse = try await minecraftToolsServerRequest(
            endpoint: "minecraft-plugins",
            query: query
        )
        
        return MinecraftCatalogSearchResult(
            projects: response.data.map(\.model),
            pagination: response.meta.pagination.model
        )
    }
    
    func fetchMinecraftPluginVersionsAPI(
        provider: MinecraftPluginProvider,
        pluginId: String,
        pluginLoader: String,
        minecraftVersion: String
    ) async throws -> [MinecraftCatalogVersion] {
        var query = [
            URLQueryItem(name: "provider", value: provider.rawValue),
            URLQueryItem(name: "plugin_id", value: pluginId)
        ]
        
        appendQueryItem(name: "plugin_loader", value: pluginLoader, query: &query)
        appendQueryItem(name: "minecraft_version", value: minecraftVersion, query: &query)
        
        let response: [MinecraftProjectVersionPayload] = try await minecraftToolsServerRequest(
            endpoint: "minecraft-plugins/versions",
            query: query
        )
        
        return response.map(\.model)
    }
    
    func installMinecraftPluginAPI(
        provider: MinecraftPluginProvider,
        pluginId: String,
        versionId: String
    ) async throws {
        let payload = MinecraftPluginInstallPayload(
            provider: provider.rawValue,
            pluginId: pluginId,
            versionId: versionId
        )
        
        try await minecraftToolsServerPost(endpoint: "minecraft-plugins/install", body: payload, timeout: 60 * 60)
    }
    
    func fetchInstalledMinecraftPluginsAPI() async throws -> [MinecraftInstalledProject] {
        let response: MinecraftInstalledProjectsPayload = try await minecraftToolsServerRequest(
            endpoint: "minecraft-plugins/installed"
        )
        
        return response.projects
    }
    
    func fetchMinecraftPolymartStatusAPI() async throws -> Bool {
        try await minecraftToolsServerRequest(
            endpoint: "minecraft-plugins/is-linked"
        )
    }
    
    func connectMinecraftPolymartAPI() async throws -> String {
        let response: String = try await minecraftToolsServerRequest(
            endpoint: "minecraft-plugins/link",
            method: .post,
            body: EmptyPayload(),
            timeout: 60
        )
        
        return response
    }
    
    func disconnectMinecraftPolymartAPI() async throws {
        try await minecraftToolsServerPost(
            endpoint: "minecraft-plugins/disconnect",
            body: EmptyPayload(),
            timeout: 60
        )
    }
    
    func fetchMinecraftModpacksAPI(
        provider: MinecraftModpackProvider,
        page: Int,
        pageSize: Int,
        searchQuery: String
    ) async throws -> MinecraftModpackSearchResult {
        var query = [
            URLQueryItem(name: "provider", value: provider.rawValue),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "page_size", value: String(pageSize))
        ]
        
        appendQueryItem(name: "search_query", value: searchQuery, query: &query)
        
        let response: MinecraftModpackListResponse = try await minecraftToolsServerRequest(
            endpoint: "minecraft-modpacks",
            query: query
        )
        
        return MinecraftModpackSearchResult(
            projects: response.data.map(\.model),
            pagination: response.meta.pagination.model,
            installedModpack: response.meta.installedModpack?.model
        )
    }
    
    func fetchMinecraftModpackVersionsAPI(
        provider: MinecraftModpackProvider,
        modpackId: String
    ) async throws -> [MinecraftCatalogVersion] {
        let response: [MinecraftProjectVersionPayload] = try await minecraftToolsServerRequest(
            endpoint: "minecraft-modpacks/versions",
            query: [
                URLQueryItem(name: "provider", value: provider.rawValue),
                URLQueryItem(name: "modpack_id", value: modpackId)
            ]
        )
        
        return response.map(\.model)
    }
    
    func installMinecraftModpackAPI(
        provider: MinecraftModpackProvider,
        modpackId: String,
        versionId: String,
        deleteServerFiles: Bool
    ) async throws {
        let payload = MinecraftModpackInstallPayload(
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
        let candidates = minecraftToolsServerCandidates
        
        for (index, serverId) in candidates.enumerated() {
            do {
                return try await performVersionChangerRequest(
                    path: "client/servers/\(serverId)/\(endpoint)\(queryPart)",
                    method: method,
                    body: body,
                    timeout: timeout
                )
            } catch {
                let isLast = index == candidates.index(before: candidates.endIndex)
                
                if isVersionChangerMissing(error), isLast == false {
                    continue
                }
                
                throw error
            }
        }
        
        throw VersionChangerError.emptyResponse
    }
    
    func minecraftToolsServerPost(endpoint: String, body: Encodable, timeout: TimeInterval) async throws {
        let candidates = minecraftToolsServerCandidates
        
        for (index, serverId) in candidates.enumerated() {
            do {
                var request = try createVersionChangerRequest(
                    path: "client/servers/\(serverId)/\(endpoint)",
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
                
                if isVersionChangerMissing(error), isLast == false {
                    continue
                }
                
                throw error
            }
        }
    }
    
    var minecraftToolsServerCandidates: [String] {
        if minecraftToolsServerId.caseInsensitiveCompare(id) == .orderedSame {
            return [minecraftToolsServerId]
        }
        
        return [minecraftToolsServerId, id]
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
    
    func performVersionChangerRequest<Response: Decodable>(
        path: String,
        method: HTTPMethod = .get,
        body: Encodable? = nil,
        timeout: TimeInterval = 60
    ) async throws -> Response {
        var request = try createVersionChangerRequest(path: path, method: method, body: body)
        request.timeoutInterval = timeout
        let (data, response) = try await URLSession.shared.data(for: request)
        
        let result: Result<Response?, Error> = processResponse(data, response, nil)
        
        switch result {
        case .success(let model):
            guard let model else {
                throw VersionChangerError.emptyResponse
            }
            
            return model
            
        case .failure(let error):
            throw error
        }
    }
    
    func versionChangerServerRequest<Response: Decodable>(endpoint: String) async throws -> Response {
        let candidates = versionChangerServerCandidates
        
        for (index, serverId) in candidates.enumerated() {
            do {
                return try await performVersionChangerRequest(
                    path: "client/extensions/versionchanger/servers/\(serverId)/\(endpoint)"
                )
            } catch {
                let isLast = index == candidates.index(before: candidates.endIndex)
                
                if isVersionChangerMissing(error), isLast == false {
                    continue
                }
                
                throw error
            }
        }
        
        throw VersionChangerError.emptyResponse
    }
    
    func versionChangerServerPost(
        endpoint: String,
        body: Encodable,
        timeout: TimeInterval
    ) async throws {
        let candidates = versionChangerServerCandidates
        
        for (index, serverId) in candidates.enumerated() {
            do {
                var request = try createVersionChangerRequest(
                    path: "client/extensions/versionchanger/servers/\(serverId)/\(endpoint)",
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
                
                if isVersionChangerMissing(error), isLast == false {
                    continue
                }
                
                throw error
            }
        }
    }
    
    var versionChangerServerCandidates: [String] {
        if versionChangerServerId.caseInsensitiveCompare(id) == .orderedSame {
            return [versionChangerServerId]
        }
        
        return [versionChangerServerId, id]
    }
    
    func createVersionChangerRequest(
        path: String,
        method: HTTPMethod = .get,
        body: Encodable? = nil
    ) throws -> URLRequest {
        guard let apiKey = Keychain.load(key: "selectedApiKey") else {
            throw VersionChangerError.noApiKey
        }
        
        guard let request = URLRequest(httpMethod: method, path: path, body: body, apiKey: apiKey) else {
            throw VersionChangerError.badRequest
        }
        
        return request
    }
    
    func isVersionChangerMissing(_ error: Error) -> Bool {
        guard let error = error as? PterError else {
            return false
        }
        
        return error.status == "404"
    }
    
    func prefetchVersionChangerTypeIcons(_ types: [VersionChangerProviderType]) {
        let iconURLs = types.compactMap(\.iconURL)
        
        guard !iconURLs.isEmpty else {
            return
        }
        
        Prefetcher.prefetchImages(iconURLs)
    }
    
    func prefetchMinecraftIcons(_ projects: [MinecraftCatalogProject]) {
        let iconURLs = projects.compactMap(\.iconURL)
        
        guard !iconURLs.isEmpty else {
            return
        }
        
        Prefetcher.prefetchImages(iconURLs)
    }
    
    func normalizeVersionChangerType(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(
                of: "[^a-z0-9]",
                with: "",
                options: .regularExpression
            )
    }
}

private enum VersionChangerError: Error {
    case noApiKey, badRequest, emptyResponse
}

private struct VersionChangerInstallPayload: Encodable {
    let build: Int
    let deleteFiles: Bool
    let acceptEula: Bool
    
    private enum CodingKeys: String, CodingKey {
        case build
        case deleteFiles = "delete_files"
        case acceptEula = "accept_eula"
    }
}

private struct VersionChangerTypesResponse: Decodable {
    let types: [String: [String: VersionChangerProviderPayload]]
}

private struct VersionChangerProviderPayload: Decodable {
    let name: String
    let icon: String
    let homepage: String?
    let description: String
    let experimental: Bool
    let deprecated: Bool
    let builds: Int
    let versions: VersionChangerProviderVersions
}

private struct VersionChangerVersionsResponse: Decodable {
    let builds: [String: VersionChangerVersionPayload]
}

private struct VersionChangerVersionPayload: Decodable {
    let type: VersionChangerReleaseType?
    let builds: Int
    let latest: VersionChangerBuild
}

private struct VersionChangerBuildsResponse: Decodable {
    let builds: [VersionChangerBuild]
}

private struct VersionChangerInstalledResponse: Decodable {
    let build: VersionChangerBuild?
    let latest: VersionChangerBuild?
}

struct VersionChangerProviderType: Identifiable, Hashable {
    let category: String
    let identifier: String
    let name: String
    let icon: String
    let homepage: String?
    let description: String
    let experimental: Bool
    let deprecated: Bool
    let builds: Int
    let versions: VersionChangerProviderVersions
    
    var id: String {
        identifier
    }
    
    var iconURL: URL? {
        let trimmed = icon.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else {
            return nil
        }
        
        if let absoluteURL = URL(string: trimmed), absoluteURL.scheme != nil {
            return absoluteURL
        }
        
        if trimmed.hasPrefix("//") {
            return URL(string: "https:\(trimmed)")
        }
        
        if trimmed.hasPrefix("/") {
            return URL(string: Endpoint.bisquitHost + trimmed)
        }
        
        return URL(string: Endpoint.bisquitHost + "/" + trimmed)
    }
}

struct VersionChangerProviderVersions: Decodable, Hashable {
    let minecraft: Int
    let project: Int
}

enum VersionChangerReleaseType: String, Decodable, Hashable {
    case release = "RELEASE"
    case snapshot = "SNAPSHOT"
}

struct VersionChangerBuild: Decodable, Hashable, Identifiable {
    let id: Int
    let type: String
    let projectVersionId: String?
    let versionId: String?
    let name: String
    let experimental: Bool
    let created: String?
}

struct VersionChangerVersion: Identifiable, Hashable {
    let version: String
    let type: VersionChangerReleaseType?
    let builds: Int
    let latest: VersionChangerBuild
    
    var id: String {
        version
    }
}

struct VersionChangerInstalled: Hashable {
    let build: VersionChangerBuild?
    let latest: VersionChangerBuild?
    
    var isOutdated: Bool {
        guard let build, let latest else {
            return false
        }
        
        return build.id != latest.id
    }
}

enum MinecraftModProvider: String, CaseIterable, Identifiable {
    case curseforge, modrinth
    
    var id: String {
        rawValue
    }
    
    var name: String {
        switch self {
        case .curseforge:
            "CurseForge"
        case .modrinth:
            "Modrinth"
        }
    }
}

enum MinecraftPluginProvider: String, CaseIterable, Identifiable {
    case curseforge, hangar, modrinth, spigotmc, polymart
    
    var id: String {
        rawValue
    }
    
    var name: String {
        switch self {
        case .curseforge:
            "CurseForge"
        case .hangar:
            "Hangar"
        case .modrinth:
            "Modrinth"
        case .spigotmc:
            "SpigotMC"
        case .polymart:
            "Polymart"
        }
    }
}

enum MinecraftModpackProvider: String, CaseIterable, Identifiable {
    case atlauncher, curseforge, feedthebeast, modrinth, technic, voidswrath
    
    var id: String {
        rawValue
    }
    
    var name: String {
        switch self {
        case .atlauncher:
            "ATLauncher"
        case .curseforge:
            "CurseForge"
        case .feedthebeast:
            "FeedTheBeast"
        case .modrinth:
            "Modrinth"
        case .technic:
            "Technic"
        case .voidswrath:
            "VoidsWrath"
        }
    }
}

struct MinecraftCatalogProject: Identifiable, Hashable {
    let id: String
    let name: String
    let description: String
    let url: String?
    let iconURLString: String?
    let externalURL: String?
    
    var iconURL: URL? {
        guard let iconURLString else {
            return nil
        }
        
        return URL(string: iconURLString)
    }
}

struct MinecraftCatalogVersion: Identifiable, Hashable {
    let id: String
    let name: String
}

struct MinecraftProjectUpdate: Hashable {
    let id: String
    let name: String
}

struct MinecraftInstalledProject: Identifiable, Hashable {
    let path: String
    let provider: String?
    let projectId: String?
    let projectName: String?
    let versionId: String?
    let versionName: String?
    let iconURLString: String?
    let update: MinecraftProjectUpdate?
    
    var id: String {
        path
    }
    
    var iconURL: URL? {
        guard let iconURLString else {
            return nil
        }
        
        return URL(string: iconURLString)
    }
}

struct MinecraftInstalledModpack: Hashable {
    let id: String
    let provider: String
    let name: String
    let description: String
    let url: String?
    let iconURLString: String?
    
    var iconURL: URL? {
        guard let iconURLString else {
            return nil
        }
        
        return URL(string: iconURLString)
    }
}

struct MinecraftPagination: Hashable {
    var currentPage: Int = 1
    var totalPages: Int = 1
    var total: Int = 0
}

private struct MinecraftCatalogSearchResult {
    let projects: [MinecraftCatalogProject]
    let pagination: MinecraftPagination
}

private struct MinecraftModpackSearchResult {
    let projects: [MinecraftCatalogProject]
    let pagination: MinecraftPagination
    let installedModpack: MinecraftInstalledModpack?
}

private struct LossyString: Decodable {
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

private struct MinecraftProjectsListResponse: Decodable {
    let data: [MinecraftProjectPayload]
    let meta: MinecraftProjectsMetaPayload
}

private struct MinecraftProjectsMetaPayload: Decodable {
    let pagination: MinecraftPaginationPayload
}

private struct MinecraftModpackListResponse: Decodable {
    let data: [MinecraftProjectPayload]
    let meta: MinecraftModpackMetaPayload
}

private struct MinecraftModpackMetaPayload: Decodable {
    let pagination: MinecraftPaginationPayload
    let installedModpack: MinecraftInstalledModpackPayload?
    
    private enum CodingKeys: String, CodingKey {
        case pagination
        case installedModpack = "installed_modpack"
    }
}

private struct MinecraftPaginationPayload: Decodable {
    let total: Int
    let currentPage: Int
    let totalPages: Int
    
    private enum CodingKeys: String, CodingKey {
        case total
        case currentPage = "current_page"
        case totalPages = "total_pages"
    }
    
    var model: MinecraftPagination {
        MinecraftPagination(
            currentPage: currentPage,
            totalPages: totalPages,
            total: total
        )
    }
}

private struct MinecraftProjectPayload: Decodable {
    let id: LossyString
    let name: String
    let shortDescription: String?
    let description: String?
    let url: String?
    let iconURL: String?
    let externalURL: String?
    
    private enum CodingKeys: String, CodingKey {
        case id, name, description, url
        case shortDescription = "short_description"
        case iconURL = "icon_url"
        case externalURL = "external_url"
    }
    
    var model: MinecraftCatalogProject {
        MinecraftCatalogProject(
            id: id.value,
            name: name,
            description: shortDescription ?? description ?? "",
            url: url,
            iconURLString: iconURL,
            externalURL: externalURL
        )
    }
}

private struct MinecraftInstalledModpackPayload: Decodable {
    let id: LossyString
    let provider: String
    let name: String
    let description: String?
    let url: String?
    let iconURL: String?
    
    private enum CodingKeys: String, CodingKey {
        case id, provider, name, description, url
        case iconURL = "icon_url"
    }
    
    var model: MinecraftInstalledModpack {
        MinecraftInstalledModpack(
            id: id.value,
            provider: provider,
            name: name,
            description: description ?? "",
            url: url,
            iconURLString: iconURL
        )
    }
}

private struct MinecraftProjectVersionPayload: Decodable {
    let id: LossyString
    let name: String?
    
    var model: MinecraftCatalogVersion {
        MinecraftCatalogVersion(
            id: id.value,
            name: name ?? id.value
        )
    }
}

private struct MinecraftInstalledProjectsPayload: Decodable {
    let projects: [MinecraftInstalledProject]
    
    init(from decoder: Decoder) throws {
        let singleValueContainer = try decoder.singleValueContainer()
        
        if let projects = try? singleValueContainer.decode([MinecraftInstalledProjectPayload].self) {
            self.projects = projects.map(\.model)
            return
        }
        
        if let identified = try? singleValueContainer.decode(MinecraftInstalledProjectsIdentifiedPayload.self) {
            self.projects = identified.identified.map(\.model)
            return
        }
        
        self.projects = []
    }
}

private struct MinecraftInstalledProjectsIdentifiedPayload: Decodable {
    let identified: [MinecraftInstalledProjectPayload]
}

private struct MinecraftInstalledProjectPayload: Decodable {
    let path: String
    let provider: String?
    let projectId: String?
    let projectName: String?
    let versionId: String?
    let versionName: String?
    let iconURL: String?
    let update: MinecraftInstalledProjectUpdatePayload?
    
    private enum CodingKeys: String, CodingKey {
        case path, provider, update
        case projectId = "project_id"
        case projectName = "project_name"
        case versionId = "version_id"
        case versionName = "version_name"
        case iconURL = "icon_url"
    }
    
    var model: MinecraftInstalledProject {
        MinecraftInstalledProject(
            path: path,
            provider: provider,
            projectId: projectId,
            projectName: projectName,
            versionId: versionId,
            versionName: versionName,
            iconURLString: iconURL,
            update: update?.model
        )
    }
}

private struct MinecraftInstalledProjectUpdatePayload: Decodable {
    let id: LossyString
    let name: String
    
    var model: MinecraftProjectUpdate {
        MinecraftProjectUpdate(
            id: id.value,
            name: name
        )
    }
}

private struct MinecraftModInstallPayload: Encodable {
    let provider: String
    let modId: String
    let versionId: String
}

private struct MinecraftPluginInstallPayload: Encodable {
    let provider: String
    let pluginId: String
    let versionId: String
}

private struct MinecraftModpackInstallPayload: Encodable {
    let provider: String
    let modpackId: String
    let modpackVersionId: String
    let deleteServerFiles: Bool
    
    private enum CodingKeys: String, CodingKey {
        case provider
        case modpackId = "modpack_id"
        case modpackVersionId = "modpack_version_id"
        case deleteServerFiles = "delete_server_files"
    }
}

private struct EmptyPayload: Encodable {}
