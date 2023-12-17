import Foundation

struct WebSocketMessage: Codable {
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
    
    var authSuccess: Bool? {
        if event == "auth success" {
            true
        } else {
            nil
        }
    }
    
    var backupCompleted: Bool? {
        if event == "backup completed" {
            true
        } else {
            nil
        }
    }
    
    var tokenExpiring: Bool? {
        if event == "token expiring" {
            true
        } else {
            nil
        }
    }
    
    var tokenExpired: Bool? {
        if event == "token expired" {
            true
        } else {
            nil
        }
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
            case rxBytes = "rx_bytes"
            case txBytes = "tx_bytes"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case state
        case memoryBytes = "memory_bytes"
        case memoryLimitBytes = "memory_limit_bytes"
        case diskBytes = "disk_bytes"
        case uptime
        case network
        case cpuAbsolute = "cpu_absolute"
    }
}
