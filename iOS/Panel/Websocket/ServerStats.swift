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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        network = (try? container.decode(ServerStatsNetwork.self, forKey: .network)) ?? .init(rxBytes: 0, txBytes: 0)
        state = (try? container.decode(String.self, forKey: .state)) ?? ""
        cpu = container.decodeLossyDouble(forKey: .cpu)
        disk = container.decodeLossyInt(forKey: .disk)
        memory = container.decodeLossyInt(forKey: .memory)
        memoryLimit = container.decodeLossyInt(forKey: .memoryLimit)
        uptime = container.decodeLossyInt(forKey: .uptime)
    }
}

struct ServerStatsNetwork: Codable {
    let rxBytes, txBytes: Int
    
    enum CodingKeys: String, CodingKey {
        case rxBytes = "rx_bytes", txBytes = "tx_bytes"
    }

    init(rxBytes: Int, txBytes: Int) {
        self.rxBytes = rxBytes
        self.txBytes = txBytes
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        rxBytes = container.decodeLossyInt(forKey: .rxBytes)
        txBytes = container.decodeLossyInt(forKey: .txBytes)
    }
}

private extension KeyedDecodingContainer {
    func decodeLossyInt(forKey key: Key) -> Int {
        if let value = try? decode(Int.self, forKey: key) {
            return value
        }
        
        if let value = try? decode(Double.self, forKey: key) {
            return Int(value)
        }
        
        if let value = try? decode(String.self, forKey: key),
           let number = Double(value) {
            return Int(number)
        }
        
        return 0
    }
    
    func decodeLossyDouble(forKey key: Key) -> Double {
        if let value = try? decode(Double.self, forKey: key) {
            return value
        }
        
        if let value = try? decode(Int.self, forKey: key) {
            return Double(value)
        }
        
        if let value = try? decode(String.self, forKey: key),
           let number = Double(value) {
            return number
        }
        
        return 0
    }
}
