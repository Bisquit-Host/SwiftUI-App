import Foundation
import OrderedCollections
import Calagopus

@Observable
final class VersionChangerVM {
    private let id: String
    private var serverID: String
    private var versionListCache: [String: [VersionChangerVersion]] = [:]
    
    init(_ id: String) {
        self.id = id
        serverID = id
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
    
    func setServerID(_ id: String) {
        guard !id.isEmpty else { return }
        
        if serverID.caseInsensitiveCompare(id) != .orderedSame {
            clearVersionListsCache()
        }
        
        serverID = id
    }
    
    func fetchVersionChangerData() async {
        isLoadingVersionChanger = true
        defer { isLoadingVersionChanger = false }
        
        do {
            async let types = fetchTypesAPI()
            async let installed = loadInstalledVersionChanger()
            
            let loadedTypes = try await types
            let installedValue = try await installed
            
            versionChangerTypes = loadedTypes
            versionChangerInstalled = await resolveInstalledVersion(installedValue)
            prefetchVersionChangerTypeIcons(loadedTypes)
            versionChangerAvailable = true
        } catch {
            if isVersionChangerMissing(error) {
                versionChangerAvailable = false
                versionChangerTypes = []
                versionChangerVersions = []
                versionChangerBuilds = []
                versionChangerInstalled = nil
                clearVersionListsCache()
                return
            }
            
            SystemAlert.error(error)
        }
    }
    
    @discardableResult
    func fetchVersions(type: String, forceRefresh: Bool = false) async -> Bool {
        guard versionChangerAvailable else {
            return true
        }
        
        let cacheKey = normalizedTypeCacheKey(type)
        
        if !forceRefresh, let cachedVersions = versionListCache[cacheKey] {
            versionChangerVersions = cachedVersions
            return true
        }
        
        do {
            let versions = try await loadVersions(type: type)
            versionChangerVersions = versions
            versionListCache[cacheKey] = versions
            return true
        } catch {
            if isCancelledRequest(error) {
                return false
            }
            
            if isVersionChangerMissing(error) {
                versionChangerAvailable = false
                clearSelection()
                clearVersionListsCache()
                return true
            }
            
            SystemAlert.error(error)
            return true
        }
    }
    
    func fetchBuilds(type: String, version: String) async {
        guard versionChangerAvailable else {
            return
        }
        
        do {
            versionChangerBuilds = []
            versionChangerBuilds = try await loadBuildDetails(type: type, version: version)
        } catch {
            if isCancelledRequest(error) {
                return
            }
            
            if isVersionChangerMissing(error) {
                versionChangerAvailable = false
                clearSelection()
                clearVersionListsCache()
                return
            }
            
            SystemAlert.error(error)
        }
    }
    
    func loadBuildDetails(type: String, version: String) async throws -> [VersionChangerBuild] {
        guard versionChangerAvailable else {
            return []
        }
        
        do {
            let builds = try await loadBuilds(type: type, version: version)
            versionChangerBuilds = builds
            
            return builds
        } catch {
            if isVersionChangerMissing(error) {
                versionChangerAvailable = false
                clearSelection()
                clearVersionListsCache()
            }
            
            throw error
        }
    }
    
    func clearSelection() {
        versionChangerVersions = []
        versionChangerBuilds = []
    }
    
    func clearVersionListsCache() {
        versionListCache = [:]
    }
    
    @discardableResult
    func installBuild(_ build: String, deleteFiles: Bool, acceptEula: Bool) async -> Bool {
        guard versionChangerAvailable else {
            return false
        }
        
        isInstallingVersionChanger = true
        defer {
            isInstallingVersionChanger = false
        }
        
        do {
            try await requestVersionInstall(build: build, deleteFiles: deleteFiles, acceptEula: acceptEula)
            await fetchInstalledVersion()
            SystemAlert.done("Version changed")
            return true
        } catch {
            if isVersionChangerMissing(error) {
                versionChangerAvailable = false
                clearSelection()
                clearVersionListsCache()
                return false
            }
            
            SystemAlert.error(error)
            return false
        }
    }
    
    func fetchInstalledVersion() async {
        guard versionChangerAvailable else {
            return
        }
        
        do {
            let installed = try await loadInstalledVersionChanger()
            versionChangerInstalled = await resolveInstalledVersion(installed)
        } catch {
            if isVersionChangerMissing(error) {
                versionChangerAvailable = false
                versionChangerInstalled = nil
                clearVersionListsCache()
                return
            }
            
            SystemAlert.error(error)
        }
    }
}

private extension VersionChangerVM {
    func fetchTypesAPI() async throws -> [VersionChangerProviderType] {
        let data = try await requestWithServerCandidates {
            try await $0.minecraftVersionTypesData(server: $1)
        }
        
        let response = try BigAssDecoder.decode(VersionChangerTypesResponse.self, from: data)
        let orderedTypes = extractOrderedTypeEntries(from: data)
        
        var output = [VersionChangerProviderType]()
        var remainingTypes = response.types
        
        for (category, identifiers) in orderedTypes {
            guard var types = remainingTypes.removeValue(forKey: category) else {
                continue
            }
            
            for identifier in identifiers {
                guard let details = types.removeValue(forKey: identifier) else {
                    continue
                }
                
                output.append(makeProviderType(category: category, identifier: identifier, details: details))
            }
            
            for (identifier, details) in types {
                output.append(makeProviderType(category: category, identifier: identifier, details: details))
            }
        }
        
        for (category, types) in remainingTypes {
            for (identifier, details) in types {
                output.append(makeProviderType(category: category, identifier: identifier, details: details))
            }
        }
        
        return output
    }
    
    func loadInstalledVersionChanger() async throws -> VersionChangerInstalled? {
        let response: VersionChangerInstalledResponse
        
        do {
            let data = try await requestWithServerCandidates {
                try await $0.installedMinecraftVersionData(server: $1)
            }
            
            response = try BigAssDecoder.decode(VersionChangerInstalledResponse.self, from: data)
        } catch {
            guard shouldFallbackToLegacyVersionChanger(after: error) else {
                throw error
            }
            
            let data = try await requestWithServerCandidates {
                try await $0.legacyMinecraftVersionData(server: $1, path: "installed")
            }
            
            response = try BigAssDecoder.decode(VersionChangerInstalledResponse.self, from: data)
        }
        
        guard response.build != nil else {
            return nil
        }
        
        return VersionChangerInstalled(build: response.build, latest: response.latest)
    }
    
    func loadVersions(type: String) async throws -> [VersionChangerVersion] {
        let response: VersionChangerVersionsResponse
        
        do {
            let data = try await requestWithServerCandidates {
                try await $0.minecraftVersionsData(server: $1, type: type)
            }
            
            response = try BigAssDecoder.decode(VersionChangerVersionsResponse.self, from: data)
        } catch {
            guard shouldFallbackToLegacyVersionChanger(after: error) else {
                throw error
            }
            
            let data = try await requestWithServerCandidates {
                try await $0.legacyMinecraftVersionData(server: $1, path: "types/\(type.uppercased())")
            }
            
            response = try BigAssDecoder.decode(VersionChangerVersionsResponse.self, from: data)
        }
        
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
    
    func loadBuilds(type: String, version: String) async throws -> [VersionChangerBuild] {
        let response: VersionChangerBuildsResponse
        
        do {
            let data = try await requestWithServerCandidates {
                try await $0.minecraftVersionBuildsData(server: $1, type: type, version: version)
            }
            response = try BigAssDecoder.decode(VersionChangerBuildsResponse.self, from: data)
        } catch {
            guard shouldFallbackToLegacyVersionChanger(after: error) else {
                throw error
            }
            
            let data = try await requestWithServerCandidates {
                try await $0.legacyMinecraftVersionData(
                    server: $1,
                    path: "types/\(type.uppercased())/\(encodedPathComponent(version))"
                )
            }
            response = try BigAssDecoder.decode(VersionChangerBuildsResponse.self, from: data)
        }
        
        return response.builds.sorted { left, right in
            if left.experimental != right.experimental {
                return left.experimental == false
            }
            
            return left.name.localizedStandardCompare(right.name) == .orderedDescending
        }
    }
    
    func requestVersionInstall(build: String, deleteFiles: Bool, acceptEula: Bool) async throws {
        do {
            try await requestWithServerCandidates {
                try await $0.installMinecraftVersion(server: $1, buildID: build, deleteFiles: deleteFiles, acceptEula: acceptEula)
            }
        } catch {
            guard shouldFallbackToLegacyVersionChanger(after: error), let legacyBuild = Int(build) else {
                throw error
            }
            
            try await requestWithServerCandidates {
                try await $0.installLegacyMinecraftVersion(
                    server: $1,
                    build: legacyBuild,
                    deleteFiles: deleteFiles,
                    acceptEula: acceptEula
                )
            }
        }
    }
    
    func extractOrderedTypeEntries(from data: Data) -> [(String, [String])] {
        var parser = VersionChangerTypesOrderParser(data)
        
        return (try? parser.parse()) ?? []
    }
    
    func isVersionChangerMissing(_ error: Error) -> Bool {
        isMissingMinecraftInstallerError(error)
    }
    
    func isCancelledRequest(_ error: Error) -> Bool {
        if let urlError = error as? URLError, urlError.code == .cancelled {
            return true
        }
        
        let nsError = error as NSError
        
        return nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled
    }
    
    func requestWithServerCandidates<Response>(
        _ request: (CalagopusClient, String) async throws -> Response
    ) async throws -> Response {
        let candidates = serverCandidates()
        let client = try CalagopusNet.client()
        
        for (index, server) in candidates.enumerated() {
            do {
                return try await request(client, server)
            } catch {
                let isLast = index == candidates.index(before: candidates.endIndex)
                
                if !isLast, isVersionChangerMissing(error) {
                    continue
                }
                
                throw error
            }
        }
        
        throw VersionChangerError.emptyResponse
    }
    
    func shouldFallbackToLegacyVersionChanger(after error: Error) -> Bool {
        isBadStatusCode(error, 404) || isBadStatusCode(error, 500)
    }
    
    func isBadStatusCode(_ error: Error, _ code: Int) -> Bool {
        return false
    }
    
    func serverCandidates() -> [String] {
        guard serverID.caseInsensitiveCompare(id) != .orderedSame else {
            return [serverID]
        }
        
        return [serverID, id]
    }
    
    func encodedPathComponent(_ value: String) -> String {
        var allowedCharacters = CharacterSet.urlPathAllowed
        allowedCharacters.remove(charactersIn: "/")
        
        return value.addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? value
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
    
    func normalizedTypeCacheKey(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()
    }
    
    func makeProviderType(
        category: String,
        identifier: String,
        details: VersionChangerProviderPayload
    ) -> VersionChangerProviderType {
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
    }
    
    func resolveInstalledVersion(_ installed: VersionChangerInstalled?) async -> VersionChangerInstalled? {
        guard let installed, let build = installed.build else {
            return installed
        }
        
        if installed.isOutdated {
            return installed
        }
        
        let installedVersionCandidates = [
            build.projectVersionId?.trimmingCharacters(in: .whitespacesAndNewlines),
            build.versionId?.trimmingCharacters(in: .whitespacesAndNewlines)
        ]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
        
        do {
            let versions = try await loadVersions(type: build.type)
            
            let matchedVersionLatest = versions.first(where: { version in
                installedVersionCandidates.contains { candidate in
                    version.version.caseInsensitiveCompare(candidate) == .orderedSame
                }
            })?.latest
            
            let globalLatest = versions.first?.latest
            let discoveredLatest = matchedVersionLatest ?? globalLatest
            
            guard let discoveredLatest else {
                return installed
            }
            
            guard discoveredLatest.id != build.id else {
                return VersionChangerInstalled(build: build, latest: discoveredLatest)
            }
            
            return VersionChangerInstalled(build: build, latest: discoveredLatest)
        } catch {
            return installed
        }
    }
}

nonisolated private enum VersionChangerError: Error {
    case noApiKey, emptyResponse
}

nonisolated private struct VersionChangerInstallPayload: Encodable, Sendable {
    let build: String
    let deleteFiles: Bool
    let acceptEula: Bool
    
    private enum CodingKeys: String, CodingKey {
        case build = "build_uuid",
             deleteFiles = "truncate_directory",
             acceptEula = "accept_eula"
    }
}

nonisolated private struct LegacyVersionChangerInstallPayload: Encodable, Sendable {
    let build: Int
    let deleteFiles: Bool
    let acceptEula: Bool
    
    private enum CodingKeys: String, CodingKey {
        case build,
             deleteFiles = "delete_files",
             acceptEula = "accept_eula"
    }
}

nonisolated private struct VersionChangerTypesResponse: Decodable {
    let types: OrderedDictionary<String, OrderedDictionary<String, VersionChangerProviderPayload>>
    
    private enum CodingKeys: String, CodingKey {
        case types
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let typesContainer = try container.nestedContainer(keyedBy: AnyCodingKey.self, forKey: .types)
        var orderedTypes = OrderedDictionary<String, OrderedDictionary<String, VersionChangerProviderPayload>>()
        
        for categoryKey in typesContainer.allKeys {
            let providersContainer = try typesContainer.nestedContainer(keyedBy: AnyCodingKey.self, forKey: categoryKey)
            var providers = OrderedDictionary<String, VersionChangerProviderPayload>()
            
            for providerKey in providersContainer.allKeys {
                providers[providerKey.stringValue] = try providersContainer.decode(
                    VersionChangerProviderPayload.self,
                    forKey: providerKey
                )
            }
            
            orderedTypes[categoryKey.stringValue] = providers
        }
        
        types = orderedTypes
    }
}

nonisolated private struct AnyCodingKey: CodingKey {
    let stringValue: String
    let intValue: Int?
    
    init?(stringValue: String) {
        self.stringValue = stringValue
        intValue = nil
    }
    
    init?(intValue: Int) {
        stringValue = "\(intValue)"
        self.intValue = intValue
    }
}

nonisolated private struct VersionChangerProviderPayload: Decodable {
    let name: String
    let icon: String
    let homepage: String?
    let description: String
    let experimental: Bool
    let deprecated: Bool
    let builds: Int
    let versions: VersionChangerProviderVersions
}

nonisolated private struct VersionChangerVersionsResponse: Decodable {
    let builds: [String: VersionChangerVersionPayload]
    
    private enum CodingKeys: String, CodingKey {
        case builds, versions
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let builds = try container.decodeIfPresent([String: VersionChangerVersionPayload].self, forKey: .builds) {
            self.builds = builds
            return
        }
        
        let page = try container.decode(VersionChangerPaginatedVersionsPayload.self, forKey: .versions)
        builds = Dictionary(uniqueKeysWithValues: page.data.map { ($0.version, $0) })
    }
}

nonisolated private struct VersionChangerVersionPayload: Decodable {
    let version: String
    let type: VersionChangerReleaseType?
    let builds: Int
    let latest: VersionChangerBuild
    
    private enum CodingKeys: String, CodingKey {
        case id, type, builds, latest
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        version = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        type = try container.decodeIfPresent(VersionChangerReleaseType.self, forKey: .type)
        builds = try container.decode(Int.self, forKey: .builds)
        latest = try container.decode(VersionChangerBuild.self, forKey: .latest)
    }
}

nonisolated private struct VersionChangerBuildsResponse: Decodable {
    let builds: [VersionChangerBuild]
    
    private enum CodingKeys: String, CodingKey {
        case builds
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let builds = try? container.decode([VersionChangerBuild].self, forKey: .builds) {
            self.builds = builds
            return
        }
        
        let page = try container.decode(VersionChangerPaginatedBuildsPayload.self, forKey: .builds)
        builds = page.data
    }
}

nonisolated private struct VersionChangerInstalledResponse: Decodable {
    let build: VersionChangerBuild?
    let latest: VersionChangerBuild?
    
    private enum CodingKeys: String, CodingKey {
        case build, latest
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let wrapper = try? container.decode(VersionChangerInstalledBuildPayload.self, forKey: .build) {
            build = wrapper.build
            latest = wrapper.latest
            return
        }
        
        build = try container.decodeIfPresent(VersionChangerBuild.self, forKey: .build)
        latest = try container.decodeIfPresent(VersionChangerBuild.self, forKey: .latest)
    }
}

nonisolated private struct VersionChangerInstalledBuildPayload: Decodable {
    let build: VersionChangerBuild?
    let latest: VersionChangerBuild?
}

nonisolated private struct VersionChangerPaginatedVersionsPayload: Decodable {
    let data: [VersionChangerVersionPayload]
}

nonisolated private struct VersionChangerPaginatedBuildsPayload: Decodable {
    let data: [VersionChangerBuild]
}

nonisolated private struct VersionChangerTypesOrderParser {
    private let source: String
    private var index: String.Index
    
    init(_ data: Data) {
        source = String(data: data, encoding: .utf8) ?? ""
        index = source.startIndex
    }
    
    mutating func parse() throws -> [(String, [String])] {
        try skipWhitespace()
        try expect("{")
        
        while true {
            try skipWhitespace()
            
            if consume("}") {
                return []
            }
            
            let key = try parseString()
            try skipWhitespace()
            try expect(":")
            try skipWhitespace()
            
            if key == "types" {
                return try parseTypesObject()
            }
            
            try skipValue()
            try skipWhitespace()
            
            if consume(",") {
                continue
            }
            
            if consume("}") {
                return []
            }
            
            throw ParsingError.invalidJSON
        }
    }
    
    private mutating func parseTypesObject() throws -> [(String, [String])] {
        try expect("{")
        var categories = [(String, [String])]()
        
        while true {
            try skipWhitespace()
            
            if consume("}") {
                return categories
            }
            
            let category = try parseString()
            try skipWhitespace()
            try expect(":")
            try skipWhitespace()
            
            let identifiers = try parseTypeIdentifiers()
            categories.append((category, identifiers))
            try skipWhitespace()
            
            if consume(",") {
                continue
            }
            
            if consume("}") {
                return categories
            }
            
            throw ParsingError.invalidJSON
        }
    }
    
    private mutating func parseTypeIdentifiers() throws -> [String] {
        try expect("{")
        var identifiers = [String]()
        
        while true {
            try skipWhitespace()
            
            if consume("}") {
                return identifiers
            }
            
            let identifier = try parseString()
            identifiers.append(identifier)
            try skipWhitespace()
            try expect(":")
            try skipWhitespace()
            try skipValue()
            try skipWhitespace()
            
            if consume(",") {
                continue
            }
            
            if consume("}") {
                return identifiers
            }
            
            throw ParsingError.invalidJSON
        }
    }
    
    private mutating func skipValue() throws {
        try skipWhitespace()
        
        guard let char = current else {
            throw ParsingError.invalidJSON
        }
        
        switch char {
        case "{":
            try skipObject()
        case "[":
            try skipArray()
        case "\"":
            _ = try parseString()
        case "t":
            try expectLiteral("true")
        case "f":
            try expectLiteral("false")
        case "n":
            try expectLiteral("null")
        default:
            if char == "-" || char.isNumber {
                try skipNumber()
            } else {
                throw ParsingError.invalidJSON
            }
        }
    }
    
    private mutating func skipObject() throws {
        try expect("{")
        
        while true {
            try skipWhitespace()
            
            if consume("}") {
                return
            }
            
            _ = try parseString()
            try skipWhitespace()
            try expect(":")
            try skipWhitespace()
            try skipValue()
            try skipWhitespace()
            
            if consume(",") {
                continue
            }
            
            if consume("}") {
                return
            }
            
            throw ParsingError.invalidJSON
        }
    }
    
    private mutating func skipArray() throws {
        try expect("[")
        
        while true {
            try skipWhitespace()
            
            if consume("]") {
                return
            }
            
            try skipValue()
            try skipWhitespace()
            
            if consume(",") {
                continue
            }
            
            if consume("]") {
                return
            }
            
            throw ParsingError.invalidJSON
        }
    }
    
    private mutating func skipNumber() throws {
        if consume("-") == false, current?.isNumber == false {
            throw ParsingError.invalidJSON
        }
        
        while let char = current, char.isNumber || char == "." || char == "-" || char == "+" || char == "e" || char == "E" {
            advance()
        }
    }
    
    private mutating func parseString() throws -> String {
        try expect("\"")
        var value = ""
        
        while let char = current {
            advance()
            
            if char == "\"" {
                return value
            }
            
            if char == "\\" {
                guard let escaped = current else {
                    throw ParsingError.invalidJSON
                }
                
                advance()
                
                switch escaped {
                case "\"": value.append("\"")
                case "\\": value.append("\\")
                case "/": value.append("/")
                case "b": value.append("\u{8}")
                case "f": value.append("\u{c}")
                case "n": value.append("\n")
                case "r": value.append("\r")
                case "t": value.append("\t")
                case "u":
                    for _ in 0..<4 {
                        guard let hex = current, hex.isHexDigit else {
                            throw ParsingError.invalidJSON
                        }
                        
                        advance()
                    }
                default:
                    throw ParsingError.invalidJSON
                }
                
                continue
            }
            
            value.append(char)
        }
        
        throw ParsingError.invalidJSON
    }
    
    private mutating func expectLiteral(_ literal: String) throws {
        for expected in literal {
            try expect(expected)
        }
    }
    
    private mutating func skipWhitespace() throws {
        while let char = current, char.isWhitespace {
            advance()
        }
    }
    
    private mutating func expect(_ expected: Character) throws {
        guard consume(expected) else {
            throw ParsingError.invalidJSON
        }
    }
    
    @discardableResult
    private mutating func consume(_ expected: Character) -> Bool {
        guard current == expected else {
            return false
        }
        
        advance()
        return true
    }
    
    private mutating func advance() {
        guard index < source.endIndex else {
            return
        }
        
        index = source.index(after: index)
    }
    
    private var current: Character? {
        guard index < source.endIndex else {
            return nil
        }
        
        return source[index]
    }
    
    private enum ParsingError: Error {
        case invalidJSON
    }
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
        "\(category)::\(identifier)"
    }
    
    var iconURL: URL? {
        if identifier.caseInsensitiveCompare("NEOFORGE") == .orderedSame,
           let bundledNeoForgeLogo = Bundle.main.url(forResource: "neoforge", withExtension: "gif") {
            return bundledNeoForgeLogo
        }
        
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

nonisolated struct VersionChangerProviderVersions: Decodable, Hashable, Sendable {
    let minecraft: Int
    let project: Int
}

nonisolated enum VersionChangerReleaseType: String, Decodable, Hashable, Sendable {
    case release = "RELEASE",
         snapshot = "SNAPSHOT"
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self).uppercased()
        
        self = VersionChangerReleaseType(rawValue: value) ?? .release
    }
}

nonisolated struct VersionChangerBuild: Decodable, Hashable, Identifiable, Sendable {
    let id: String
    let type: String
    let projectVersionId: String?
    let versionId: String?
    let name: String
    let experimental: Bool
    let created: String?
    
    private enum CodingKeys: String, CodingKey {
        case id,
             uuid,
             build,
             type,
             projectVersionId,
             projectVersionIdSnakeCase = "project_version_id",
             versionId,
             versionIdSnakeCase = "version_id",
             name,
             experimental,
             created
    }
    
    init(
        id: String,
        type: String,
        projectVersionId: String?,
        versionId: String?,
        name: String,
        experimental: Bool,
        created: String?
    ) {
        self.id = id
        self.type = type
        self.projectVersionId = projectVersionId
        self.versionId = versionId
        self.name = name
        self.experimental = experimental
        self.created = created
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decodeIfPresent(String.self, forKey: .uuid)
        ?? container.decodeIfPresent(String.self, forKey: .id)
        ?? container.decodeIfPresent(String.self, forKey: .build)
        ?? container.decodeIfPresent(Int.self, forKey: .uuid).map(String.init)
        ?? container.decodeIfPresent(Int.self, forKey: .id).map(String.init)
        ?? container.decode(Int.self, forKey: .build).description
        type = try container.decode(String.self, forKey: .type)
        projectVersionId = try container.decodeIfPresent(String.self, forKey: .projectVersionId)
        ?? container.decodeIfPresent(String.self, forKey: .projectVersionIdSnakeCase)
        versionId = try container.decodeIfPresent(String.self, forKey: .versionId)
        ?? container.decodeIfPresent(String.self, forKey: .versionIdSnakeCase)
        name = try container.decode(String.self, forKey: .name)
        experimental = try container.decodeIfPresent(Bool.self, forKey: .experimental) ?? false
        created = try container.decodeIfPresent(String.self, forKey: .created)
    }
}

struct VersionChangerVersion: Identifiable, Hashable {
    let version: String
    let type: VersionChangerReleaseType?
    let builds: Int
    let latest: VersionChangerBuild
    
    var id: String {
        "\(version)::\(latest.id)"
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
