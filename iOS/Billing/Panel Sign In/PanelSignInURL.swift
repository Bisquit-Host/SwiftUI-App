import Foundation

nonisolated enum PanelSignInURL {
    private static let webHosts = ["my.bisquit.host", "test-my.bisquit.host"]
    private static let authorizationPath = "/oidc/authorize"
    private static let requestIDName = "request_id"

    static func requestID(from url: URL) -> String? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }

        guard isAuthorizationURL(components) else {
            return nil
        }

        guard
            let requestID = components.queryItems?
                .first(where: { $0.name == requestIDName })?
                .value?
                .trimmingCharacters(in: .whitespacesAndNewlines),
            !requestID.isEmpty
        else {
            return nil
        }

        return requestID
    }

    private static func isAuthorizationURL(_ components: URLComponents) -> Bool {
        switch components.scheme?.lowercased() {
        case "https":
            guard let host = components.host?.lowercased(), webHosts.contains(host) else {
                return false
            }

            return components.path == authorizationPath
        case "bisq":
            return components.host?.lowercased() == "oidc" && components.path == "/authorize"
        default:
            return false
        }
    }
}
