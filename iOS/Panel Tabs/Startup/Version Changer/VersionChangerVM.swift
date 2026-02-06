import Foundation
import PteroNet

@Observable
final class VersionChangerVM {
    private let id: String
    private var serverId: String

    init(_ id: String) {
        self.id = id
        serverId = id
    }

    private(set) var isLoadingVersionChanger = false
    private(set) var isInstallingVersionChanger = false
    private(set) var versionChangerAvailable = true
    private(set) var versionChangerTypes: [VersionChangerProviderType] = []
    private(set) var versionChangerVersions: [VersionChangerVersion] = []
    private(set) var versionChangerBuilds: [VersionChangerBuild] = []
    private(set) var versionChangerInstalled: VersionChangerInstalled?

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

    func setServerId(_ id: String) {
        guard !id.isEmpty else {
            return
        }

        serverId = id
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

            versionChangerTypes = loadedTypes
            versionChangerInstalled = try await installed
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

private extension VersionChangerVM {
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
        let candidates = serverCandidates

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

    func versionChangerServerPost(endpoint: String, body: Encodable, timeout: TimeInterval) async throws {
        let candidates = serverCandidates

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

    var serverCandidates: [String] {
        if serverId.caseInsensitiveCompare(id) == .orderedSame {
            return [serverId]
        }

        return [serverId, id]
    }

    func createVersionChangerRequest(path: String, method: HTTPMethod = .get, body: Encodable? = nil) throws -> URLRequest {
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
        guard !iconURLs.isEmpty else { return }

        Prefetcher.prefetchImages(iconURLs)
    }

    func normalizeVersionChangerType(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: "[^a-z0-9]", with: "", options: .regularExpression)
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
        case build,
             deleteFiles = "delete_files",
             acceptEula = "accept_eula"
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
    case release = "RELEASE",
         snapshot = "SNAPSHOT"
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
