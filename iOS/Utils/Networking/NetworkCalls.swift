import ScrechKit
import Calagopus

final class CalagopusNet {
    static func powerSignal(_ id: String, do signal: CalagopusServerPowerAction) async {
        grantAchievement("restart_server")
        
        do {
            try await client().power(server: id, action: signal)
        } catch {
            networkCallError(#function, error)
        }
    }
    
    static func sendCommand(_ id: String, command: String) async {
        do {
            try await client().command(server: id, command: command)
        } catch {
            networkCallError(#function, error)
        }
    }
    
    static func reinstallServer(_ id: String, onSuccess: @escaping () -> Void = {}) async {
        do {
            try await client().reinstall(server: id)
            onSuccess()
        } catch {
            networkCallError(#function, error)
        }
    }
    
    static func client() throws -> CalagopusClient {
        if let apiKey = Keychain.load(key: "selectedApiKey"), !apiKey.isEmpty {
            return CalagopusClient(baseURL: CalagopusEndpointDefaults.currentBaseURL, apiKey: apiKey)
        }
        
        if let apiKey = ProcessInfo.processInfo.environment["CALAGOPUS_API_KEY"], !apiKey.isEmpty {
            return CalagopusClient(baseURL: CalagopusEndpointDefaults.currentBaseURL, apiKey: apiKey)
        }
        
        throw CalagopusNetError.missingAPIKey
    }
}

private enum CalagopusNetError: LocalizedError {
    case missingAPIKey
    
    var errorDescription: String? {
        "Missing Calagopus API key"
    }
}

nonisolated enum HTTPMethod: String {
    case get, post, put, patch, delete
}

nonisolated enum MinecraftInstallerRequestError: LocalizedError {
    case noApiKey, emptyResponse, badStatusCode(Int)
    
    var errorDescription: String? {
        switch self {
        case .noApiKey:
            "No API key found"
        case .emptyResponse:
            "Empty response"
        case .badStatusCode(let statusCode):
            "Request failed with status \(statusCode)"
        }
    }
}

nonisolated struct BigAssDecoder {
    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            
            if let date = BigAssDateFormatters.iso8601WithFractionalSeconds.date(from: string) {
                return date
            }
            
            if let date = BigAssDateFormatters.iso8601.date(from: string) {
                return date
            }
            
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid ISO 8601 date: \(string)")
        }
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return decoder
    }()
    
    static func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        try decoder.decode(T.self, from: data)
    }
    
    private init() {}
}

nonisolated extension URLRequest {
    init?(httpMethod: HTTPMethod = .get, path: String, body: Encodable? = nil, apiKey: String) {
        let absoluteString = CalagopusEndpointDefaults.currentBaseURL.absoluteString
        let baseURLString = absoluteString.hasSuffix("/") ? String(absoluteString.dropLast()) : absoluteString
        let urlString = "\(baseURLString)/api/\(path)"
        
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        self.init(url: url)
        self.httpMethod = httpMethod.rawValue.uppercased()
        setValue("application/json", forHTTPHeaderField: "Accept")
        setValue("CalagopusSwift", forHTTPHeaderField: "User-Agent")
        setValue(apiKey.hasPrefix("Bearer ") ? apiKey : "Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        if let body {
            do {
                httpBody = try JSONEncoder().encode(body)
                setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                return nil
            }
        }
    }
}

nonisolated func fetchMinecraftReleaseVersionsFromManifestAPI() async throws -> [String] {
    try await MinecraftVersionManifestLoader.shared.fetchReleaseVersions()
}

nonisolated func fetchMinecraftInstallerExternalData(
    urlString: String,
    timeout: TimeInterval = 20,
    accept: String = "application/json",
    userAgent: String = "Bisquit-Host"
) async throws -> Data {
    guard let url = URL(string: urlString) else {
        throw URLError(.badURL)
    }
    
    return try await fetchMinecraftInstallerExternalData(url: url, timeout: timeout, accept: accept, userAgent: userAgent)
}

nonisolated func fetchMinecraftInstallerExternalData(
    url: URL,
    timeout: TimeInterval = 20,
    accept: String = "application/json",
    userAgent: String = "Bisquit-Host"
) async throws -> Data {
    var request = URLRequest(url: url)
    request.timeoutInterval = timeout
    request.setValue(accept, forHTTPHeaderField: "Accept")
    request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse else {
        throw MinecraftInstallerRequestError.emptyResponse
    }
    
    guard (200...299).contains(httpResponse.statusCode) else {
        throw MinecraftInstallerRequestError.badStatusCode(httpResponse.statusCode)
    }
    
    return data
}

nonisolated func isMissingMinecraftInstallerError(_ error: Error) -> Bool {
    if case CalagopusError.httpStatus(let statusCode, _, _) = error {
        return statusCode == 404
    }
    
    if case MinecraftInstallerRequestError.badStatusCode(let statusCode) = error {
        return statusCode == 404
    }
    
    return false
}

nonisolated private enum BigAssDateFormatters {
    static var iso8601WithFractionalSeconds: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }
    
    static var iso8601: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }
}

private actor MinecraftVersionManifestLoader {
    static let shared = MinecraftVersionManifestLoader()
    
    private let manifestURL = URL(string: "https://piston-meta.mojang.com/mc/game/version_manifest_v2.json")
    private let cacheTTL: TimeInterval = 60 * 60
    private var cachedReleaseVersions: [String] = []
    private var lastFetchAt: Date?
    
    func fetchReleaseVersions() async throws -> [String] {
        if let lastFetchAt,
           Date().timeIntervalSince(lastFetchAt) < cacheTTL,
           !cachedReleaseVersions.isEmpty {
            return cachedReleaseVersions
        }
        
        guard let manifestURL else {
            throw URLError(.badURL)
        }
        
        let data = try await fetchMinecraftInstallerExternalData(url: manifestURL)
        let payload = try JSONDecoder().decode(MinecraftManifestPayload.self, from: data)
        let releases = normalizedOptions(payload.versions.filter { $0.type == "release" }.map(\.id))
        
        guard !releases.isEmpty else {
            throw MinecraftInstallerRequestError.emptyResponse
        }
        
        cachedReleaseVersions = releases
        lastFetchAt = Date()
        return releases
    }
    
    private func normalizedOptions(_ values: [String]) -> [String] {
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
}

nonisolated private struct MinecraftManifestPayload: Decodable {
    let versions: [MinecraftManifestVersionPayload]
}

nonisolated private struct MinecraftManifestVersionPayload: Decodable {
    let id: String
    let type: String
}
