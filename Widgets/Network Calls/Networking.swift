import PteroNet

struct Networking {
    static func fetchServers() async -> [Asset] {
        do {
            let model = try await serverListAPI().data
            
            return model.map {
                let server = $0.attributes
                return Asset(id: server.id, name: server.name)
            }
        } catch {
            return [Asset(id: "69.2", name: "\(error)")]
        }
    }
    
    static func fetchResourceUsage(_ id: String) async -> AssetDetails {
        do {
            let model = try await serverUsageAPI(id)
            return AssetDetails(state: model.state.rawValue, test: model)
        } catch {
            return AssetDetails(state: "\(error)")
        }
    }
}
