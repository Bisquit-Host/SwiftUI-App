import PteroNet

extension UserDefaults {
    func setServerAttributesArray(_ servers: [ServerAttributes], forKey key: String) {
        let encoder = JSONEncoder()
        
        if let data = try? encoder.encode(servers) {
            set(data, forKey: key)
        }
    }
    
    func serverAttributesArray(forKey key: String) -> [ServerAttributes]? {
        guard let data = data(forKey: key) else {
            return nil
        }
        
        let decoder = JSONDecoder()
        
        return try? decoder.decode([ServerAttributes].self, from: data)
    }
}
