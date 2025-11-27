struct ServerStats: Codable {
    let network: Network
    let state: String
    let cpu, memory, disk: Double
    let memoryLimitBytes, uptime: Int
    
    struct Network: Codable {
        let rxBytes, txBytes: Int
    }
    
    enum CodingKeys: String, CodingKey {
        case state, uptime, network, memoryLimitBytes,
             disk = "disk_bytes",
             cpu = "cpu_absolute",
             memory = "memory_bytes"
    }
}
