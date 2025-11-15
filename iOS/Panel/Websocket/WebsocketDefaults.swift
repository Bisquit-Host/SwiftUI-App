import Foundation

enum WebsocketDefaults {
    static let origin = URL(string: "https://mgr.bisquit.host")!
    static let logStreamPayload = "{\"event\":\"send logs\",\"args\":[\"null\"]}"
}
