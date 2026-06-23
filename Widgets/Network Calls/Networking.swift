import Calagopus

struct Networking {
    static func fetchServers() async -> [Asset] {
        do {
            let model = try await CalagopusNet.client().servers(perPage: 100).data
            
            return model.map {
                Asset(id: $0.id, name: $0.name)
            }
        } catch {
            return [Asset(id: "69.2", name: "\(error)")]
        }
    }
    
    static func fetchResourceUsage(_ id: String) async -> AssetDetails {
        do {
            let model = try await CalagopusNet.client().resources(server: id)
            return AssetDetails(state: model.state.rawValue, test: model)
        } catch {
            return AssetDetails(state: "\(error)")
        }
    }
}
