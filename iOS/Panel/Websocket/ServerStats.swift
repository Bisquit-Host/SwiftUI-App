struct ServerStats: Codable {
    let network: ServerStatsNetwork
    let state: String
    let cpu: Double
    let disk, memory, memoryLimit, uptime: Int
    
    enum CodingKeys: String, CodingKey {
        case state, uptime, network,
             disk = "disk_bytes",
             cpu = "cpu_absolute",
             memory = "memory_bytes",
             memoryLimit = "memory_limit_bytes"
    }
}

struct ServerStatsNetwork: Codable {
    let rxBytes, txBytes: Int
    
    enum CodingKeys: String, CodingKey {
        case rxBytes = "rx_bytes",
             txBytes = "tx_bytes"
    }
}
