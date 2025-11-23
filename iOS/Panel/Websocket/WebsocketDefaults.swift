import Foundation

enum WebsocketDefaults {
    static let origin = URL(string: Endpoint.bisquitPter)!
    static let logStreamPayload = "{\"event\":\"send logs\",\"args\":[\"null\"]}"
}
