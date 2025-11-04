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
        if event == "stats", let args, args.count > 0 {
            if let data = args[0].data(using: .utf8),
               let stats = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                return stats
            }
        }
        
        return nil
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

struct ServerStats: Codable {
    let network: Network
    let state: String
    let cpuAbsolute, memoryBytes, diskBytes: Double
    let memoryLimitBytes, uptime: Int
    
    struct Network: Codable {
        let rxBytes, txBytes: Int
        
        enum CodingKeys: String, CodingKey {
            case rxBytes = "rx_bytes",
                 txBytes = "tx_bytes"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case state,
             uptime,
             network,
             diskBytes = "disk_bytes",
             cpuAbsolute = "cpu_absolute",
             memoryBytes = "memory_bytes",
             memoryLimitBytes = "memory_limit_bytes"
    }
}
