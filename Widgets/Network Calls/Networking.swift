import PteroNet

struct Networking {
    static func fetchServers() async throws -> [Asset] {
        var assets: [Asset] = []
        
        serverListAPI { result in
            switch result {
            case .success(let model):
                guard let model = model?.data else {
                    return
                }
                
                for server in model.map(\.attributes) {
                    let asset = Asset(
                        id: server.id,
                        name: server.name
                    )
                    
                    assets.append(asset)
                }
                
            case .failure(let error):
                let errorAsset = Asset(id: "69.2", name: error.localizedDescription)
                
                assets.append(errorAsset)
            }
        }
        
        return assets
    }
    
    static func fetchResourceUsage(_ id: String) async -> AssetDetails {
        let assetDetails: AssetDetails
        
        do {
            guard let request = URLRequest(
                path: "client/servers/\(id)/resources"
            ) else {
                return AssetDetails(
                    state: "Error creating request"
                )
            }
            
            let (data, _) = try await URLSession.shared.data(for: request)
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let json = try decoder.decode(ResourceUsageResponse.self, from: data)
            
            let state = json.attributes.state
            
            assetDetails = AssetDetails(
                state: state,
                test: json.attributes
            )
        } catch {
            assetDetails = AssetDetails(
                state: error.localizedDescription
            )
        }
        
        return assetDetails
    }
}
