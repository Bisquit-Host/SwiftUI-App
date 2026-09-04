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
#if os(iOS) || os(visionOS)
        if let credential = PanelSessionStore.load(), credential.isUsable {
            return CalagopusClient(
                baseURL: credential.baseURL ?? CalagopusClient.defaultBaseURL,
                session: PanelSessionURLProtocol.session
            )
        }
        
        if accessToken() != nil {
            return CalagopusClient(session: PanelSessionURLProtocol.session)
        }
#endif
        
        return CalagopusClient()
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
