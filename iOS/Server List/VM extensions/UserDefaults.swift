import Calagopus

extension UserDefaults {
    func setServerAttributesArray(_ servers: [CalagopusServer], forKey key: String) {
        let encoder = JSONEncoder()
        
        if let data = try? encoder.encode(servers) {
            set(data, forKey: key)
        }
    }
    
    func serverAttributesArray(forKey key: String) -> [CalagopusServer]? {
        guard let data = data(forKey: key) else {
            return nil
        }
        
        do {
            return try BigAssDecoder.decode([CalagopusServer].self, from: data)
        } catch {
            Logger().error("Error loading cached servers: \(error)")
            removeObject(forKey: key) // clear corrupted cache so future loads start clean
            return nil
        }
    }
}
