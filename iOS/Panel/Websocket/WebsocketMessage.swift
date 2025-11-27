import Foundation

struct WebsocketMessage: Codable {
    let event: String
    let args: [String]?
    
    var consoleOutput: String? {
        if event == "console output", let args = args, args.count > 0 {
            args[0]
        } else {
            nil
        }
    }
    
    var serverStats: [String: Any]? {
        guard
            event == "stats", let args, args.count > 0,
            let data = args[0].data(using: .utf8),
            let stats = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        else {
            return nil
        }
        
        return stats
    }
    
    var serverStatus: String? {
        if event == "status", let args = args, args.count > 0 {
            args[0]
        } else {
            nil
        }
    }
    
    var authSuccess: Bool {
        event == "auth success"
    }
    
    var backupCompleted: Bool {
        event == "backup completed"
    }
    
    var tokenExpiring: Bool {
        event == "token expiring"
    }
    
    var tokenExpired: Bool {
        event == "token expired"
    }
}
