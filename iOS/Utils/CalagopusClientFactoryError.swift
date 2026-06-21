import Foundation

enum CalagopusClientFactoryError: LocalizedError {
    case missingAPIKey

    var errorDescription: String? {
        "Missing Calagopus API key"
    }
}
