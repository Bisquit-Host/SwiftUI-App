import Foundation
import OrderedCollections
import PteroNet

@Observable
final class VersionChangerVM {
    private let id: String
    private var serverId: String
    private var versionListCache: [String: [VersionChangerVersion]] = [:]
    
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
        guard !id.isEmpty else { return }
        
        if serverId.caseInsensitiveCompare(id) != .orderedSame {
            clearVersionListsCache()
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
    
    func fetchVersionChangerVersions(type: String, forceRefresh: Bool = false) async {
        guard versionChangerAvailable else {
            return
        }
        
        let cacheKey = normalizedTypeCacheKey(type)
        
        if !forceRefresh, let cachedVersions = versionListCache[cacheKey] {
            versionChangerVersions = cachedVersions
            return
        }
        
        do {
            let versions = try await loadVersionChangerVersions(type: type)
            versionChangerVersions = versions
            versionListCache[cacheKey] = versions
        } catch {
            if isVersionChangerMissing(error) {
                versionChangerAvailable = false
                clearVersionChangerSelection()
                clearVersionListsCache()
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
            versionChangerBuilds = try await loadVersionChangerBuilds(type: type, version: version)
        } catch {
            if isVersionChangerMissing(error) {
                versionChangerAvailable = false
                clearVersionChangerSelection()
                clearVersionListsCache()
                return
            }
            
            SystemAlert.error(error)
        }
    }
    
    func clearVersionChangerSelection() {
        versionChangerVersions = []
        versionChangerBuilds = []
    }
    
    func clearVersionListsCache() {
        versionListCache = [:]
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
            try await requestVersionChangerInstall(build: build, deleteFiles: deleteFiles, acceptEula: acceptEula)
            await fetchInstalledVersionChanger()
            SystemAlert.done("Version changed")
            return true
        } catch {
            if isVersionChangerMissing(error) {
                versionChangerAvailable = false
                clearVersionChangerSelection()
                clearVersionListsCache()
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
    func fetchVersionChangerTypesAPI() async throws -> [VersionChangerProviderType] {
        let data = try await fetchVersionChangerTypesDataAPI(
            apiKey: apiKey(),
            serverId: serverId,
            fallbackServerId: id
        )
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
        let response: VersionChangerInstalledResponse = try await fetchInstalledVersionChangerAPI(
            apiKey: apiKey(),
            serverId: serverId,
            fallbackServerId: id
        )
        
        guard response.build != nil else {
            return nil
        }
        
        return VersionChangerInstalled(build: response.build, latest: response.latest)
    }
    
    func loadVersionChangerVersions(type: String) async throws -> [VersionChangerVersion] {
        let response: VersionChangerVersionsResponse = try await fetchVersionChangerVersionsAPI(
            apiKey: apiKey(),
            serverId: serverId,
            fallbackServerId: id,
            type: type
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
    
    func loadVersionChangerBuilds(type: String, version: String) async throws -> [VersionChangerBuild] {
        let response: VersionChangerBuildsResponse = try await fetchVersionChangerBuildsAPI(
            apiKey: apiKey(),
            serverId: serverId,
            fallbackServerId: id,
            type: type,
            version: version
        )
        
        return response.builds.sorted { left, right in
            if left.experimental != right.experimental {
                return left.experimental == false
            }
            
            return left.name.localizedStandardCompare(right.name) == .orderedDescending
        }
    }
    
    func requestVersionChangerInstall(build: Int, deleteFiles: Bool, acceptEula: Bool) async throws {
        let payload = VersionChangerInstallPayload(
            build: build,
            deleteFiles: deleteFiles,
            acceptEula: acceptEula
        )
        
        try await installVersionChangerAPI(
            apiKey: apiKey(),
            serverId: serverId,
            fallbackServerId: id,
            body: payload
        )
    }
    
    func extractOrderedTypeEntries(from data: Data) -> [(String, [String])] {
        var parser = VersionChangerTypesOrderParser(data)
        
        return (try? parser.parse()) ?? []
    }
    
    func isVersionChangerMissing(_ error: Error) -> Bool {
        isMissingMinecraftInstallerError(error)
    }
    
    func apiKey() throws -> String {
        guard let apiKey = Keychain.load(key: "selectedApiKey") else {
            throw VersionChangerError.noApiKey
        }
        
        return apiKey
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
            let versions = try await loadVersionChangerVersions(type: build.type)
            
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
            
            if let providedLatest = installed.latest, providedLatest.id > discoveredLatest.id {
                return VersionChangerInstalled(build: build, latest: providedLatest)
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
}

nonisolated private struct VersionChangerVersionPayload: Decodable {
    let type: VersionChangerReleaseType?
    let builds: Int
    let latest: VersionChangerBuild
}

nonisolated private struct VersionChangerBuildsResponse: Decodable {
    let builds: [VersionChangerBuild]
}

nonisolated private struct VersionChangerInstalledResponse: Decodable {
    let build: VersionChangerBuild?
    let latest: VersionChangerBuild?
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
}

nonisolated struct VersionChangerBuild: Decodable, Hashable, Identifiable, Sendable {
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
