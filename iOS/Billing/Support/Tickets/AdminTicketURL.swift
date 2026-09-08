import Foundation

nonisolated enum AdminTicketURL {
    static func ticketID(from url: URL) -> Int? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              components.scheme?.lowercased() == "https",
              let host = components.host?.lowercased(),
              ["my.bisquit.host", "test-my.bisquit.host"].contains(host),
              components.user == nil,
              components.password == nil,
              components.port == nil || components.port == 443 else {
            return nil
        }

        let path = components.path.split(separator: "/", omittingEmptySubsequences: false)
        guard path.count == 4 || (path.count == 5 && path.last == ""),
              path[0].isEmpty,
              path[1] == "admin",
              path[2] == "support",
              !path[3].isEmpty,
              path[3].allSatisfy({ $0.isASCII && $0.isNumber }),
              let ticketID = Int(path[3]), ticketID > 0 else {
            return nil
        }

        return ticketID
    }
}
