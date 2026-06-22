import Foundation
import Calagopus

enum CalagopusClientFactory {
    static func client() throws -> CalagopusClient {
        if let apiKey = Keychain.load(key: "selectedApiKey"), !apiKey.isEmpty {
            return CalagopusClient(baseURL: CalagopusEndpointDefaults.currentBaseURL, apiKey: apiKey)
        }

        if let apiKey = ProcessInfo.processInfo.environment["CALAGOPUS_API_KEY"], !apiKey.isEmpty {
            return CalagopusClient(baseURL: CalagopusEndpointDefaults.currentBaseURL, apiKey: apiKey)
        }

        throw CalagopusClientFactoryError.missingAPIKey
    }
}
