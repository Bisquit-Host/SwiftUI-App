import Foundation
import PteroNet

@Observable
final class StartupVM {
    private let id: String
    private var versionChangerServerId: String
    
    init(_ id: String) {
        self.id = id
        versionChangerServerId = id
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
        guard let type = versionChangerInstalled?.build?.type else {
            return nil
        }
        
        return versionChangerTypes.first {
            $0.identifier.caseInsensitiveCompare(type) == .orderedSame
        }
    }
    
    func setVersionChangerServerId(_ id: String) {
        guard !id.isEmpty else {
            return
        }
        
        versionChangerServerId = id
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
            
            self.versionChangerTypes = try await types
            self.versionChangerInstalled = try await installed
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
    
    func performVersionChangerRequest<Response: Decodable>(path: String) async throws -> Response {
        let request = try createVersionChangerRequest(path: path)
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
