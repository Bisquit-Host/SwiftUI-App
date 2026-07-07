import Foundation
import Calagopus

enum CalagopusClientFactory {
    static func client() throws -> CalagopusClient {
        try CalagopusNet.client()
    }
}
